function calculate_losses!(result, data)
    for (l, branch) in result["solution"]["branch"]
        branch["ploss"] = branch["pf"] + branch["pt"]
    end
    result["totalloss"] = sum(branch["ploss"] for (l, branch) in result["solution"]["branch"])

    result["totalload"] = sum(load["pd"] for (l, load) in data["load"])

    result["totalgen"] = sum(gen["pg"] for (l, gen) in result["solution"]["gen"])

    return result["totalloss"]
end

"This function accepts a data dictionary, and returns a new data dictionary
with perturbation applied"
function create_impedance_perturbation(data_input, α, ϵ, λ)
    # Create a copy of the input so that a new dataset is returned
    data = deepcopy(data_input)

    # First apply the Laplace noise to each branch
    distribution = Distributions.Laplace(0, 3 * α / ϵ)
    sum_g = 0
    sum_b = 0
    sum_g_shunt = 0
    sum_b_shunt = 0
    for (l, branch) in data["branch"]
        noise = Random.rand(distribution, 1)[1]
        noise_shunt = Random.rand(distribution, 1)[1]
        z = branch["br_r"] + im*branch["br_x"]
        y = 1 / z
        g = real(y)
        b = imag(y)
        g_shunt = branch["g_to"] #assumes it is equal to branch["g_fr"]
        b_shunt = branch["b_to"] #assumes it is equal to branch["b_fr"]
        # println("g is: ", g)
        # println("b is: ", b)

        # Handle the case where resistance is 0 to avoid undefined behaviour
        if branch["br_r"] != 0
            r = b / g # Algorithm 1 and eq. (15)
            pert_b = b + noise
            pert_g = pert_b / r
        else
            pert_g = 0
            pert_b = b + noise # Just apply perturbation to b
        end

        pert_b_shunt = b_shunt + noise_shunt
        pert_g_shunt = g_shunt # Removed the perturbation of g_shunt

        branch["g_obj"] = pert_g
        branch["b_obj"] = pert_b
        branch["g_shunt_obj"] = pert_g_shunt
        branch["b_shunt_obj"] = pert_b_shunt
        # println("perturbed g is: ", pert_g)
        # println("perturbed b is: ", pert_b)
        sum_g += g
        sum_b += b
        sum_g_shunt += g_shunt
        sum_b_shunt += b_shunt
    end

    # Apply the noisy mean limit values for s4 and s5
    n = length(data["branch"])
    lap_μ = Distributions.Laplace(0, 3 * α / (n * ϵ))

    μ_g = (1 / n) * sum_g + Random.rand(lap_μ, 1)[1] # Eq 16
    μ_b = (1 / n) * sum_b + Random.rand(lap_μ, 1)[1] # Eq 17
    μ_g_shunt = (1 / n) * sum_g_shunt + Random.rand(distribution, 1)[1]
    μ_b_shunt = (1 / n) * sum_b_shunt + Random.rand(distribution, 1)[1]

    # Add noisy mean limit values to our data dictionary
    # Note that we use min and max to handle negative parameters
    data["g_lb"] = min(μ_g / λ, μ_g * λ)
    data["g_ub"] = max(μ_g / λ, μ_g * λ)
    data["b_lb"] = min(μ_b / λ, μ_b * λ)
    data["b_ub"] = max(μ_b / λ, μ_b * λ)
    data["g_lb_shunt"] = min(μ_g_shunt / λ, μ_g_shunt * λ)
    data["g_ub_shunt"] = max(μ_g_shunt / λ, μ_g_shunt * λ)
    data["b_lb_shunt"] = min(μ_b_shunt / λ, μ_b_shunt * λ)
    data["b_ub_shunt"] = max(μ_b_shunt / λ, μ_b_shunt * λ)
    @show data["b_lb_shunt"], data["b_ub_shunt"]

    return data
end


function overwrite_impedances_in_data!(result, data)
    for (l, branch) in result["solution"]["branch"]
        y = branch["g"] + im* branch["b"]
        z = 1/y
        r = real(z)
        x = imag(z)
        b = branch["b_shunt"]
        data["branch"][l]["br_r"] = r
        data["branch"][l]["br_x"] = x
        data["branch"][l]["b_fr"] = b
        data["branch"][l]["b_to"] = b
    end
end


"Helper function to accept a node, and return a list of adjacent branches to iterate through"
function get_adjacent_branches(data, current_bus, target_branch)
    adjacent_branches = []
    for (l, branch) in data["branch"]
        # Check each branch to see which branches connect to the current node
        # Don't include the target branch
        if (branch["f_bus"] == current_bus["bus_i"] || branch["t_bus"] == current_bus["bus_i"]) && target_branch["index"] != parse(Int, l)
            push!(adjacent_branches, branch)
        end
    end
    return adjacent_branches
end


"Helper function to find the root node in a model"
function get_root_bus(data)
    for (i, bus) in data["bus"]
        if bus["bus_type"] == 3
            return parse(Int, i)
        end
    end
    return 0
end


"Recursive Breadth First Search function to find all nodes on a given side of a branch"
function recursive_connected_nodes(data, target_branch, current_bus, connected_bus_set)
    # If we have already visited this node, return
    if current_bus["bus_i"] in connected_bus_set
        return
    end
    # We are exploring this node, so add it to the explored set
    push!(connected_bus_set, current_bus["bus_i"])

    # Loop through each adjacent branch and explore recursively
    for adjacent_branch in get_adjacent_branches(data, current_bus, target_branch)
        recursive_connected_nodes(data, target_branch, data["bus"][string(adjacent_branch["t_bus"])], connected_bus_set)
        recursive_connected_nodes(data, target_branch, data["bus"][string(adjacent_branch["f_bus"])], connected_bus_set)
    end

end


"Recursive Depth First Search to find the path from a node to the root node"
function dfs_to_root(data, target_branch, current_bus, dfs_stack, root_bus_id)
    # If we have already visited this node, return
    if current_bus["bus_i"] in dfs_stack
        return false
    end
    # We are exploring this node, so add it to the explored set
    push!(dfs_stack, current_bus["bus_i"])

    # If this is the root node, exit DFS
    if current_bus["bus_i"] == root_bus_id
        return true
    end

    # Loop through each adjacent branch and explore recursively
    # If we find the root node, exit DFS
    for adjacent_branch in get_adjacent_branches(data, current_bus, target_branch)
        if dfs_to_root(data, target_branch, data["bus"][string(adjacent_branch["t_bus"])], dfs_stack, root_bus_id)
            return true
        end
        if dfs_to_root(data, target_branch, data["bus"][string(adjacent_branch["f_bus"])], dfs_stack, root_bus_id)
            return true
        end
    end
    pop!(dfs_stack)
    return false

end

""
function set_upstream_downstream_nodes_branches!(data, target_branch)
    # For the given branch, explore all buses to the f side of it
    # println("Looking for f nodes for branch ", target_branch["index"])
    f_direction_buses = Vector{Int}()
    closest_f_bus = data["bus"][string(target_branch["f_bus"])]
    recursive_connected_nodes(data, target_branch, closest_f_bus, f_direction_buses)
    # println(f_direction_buses)
    # println()

    # For the given branch, explore all buses to the t side of it
    # println("Looking for t nodes for branch ", target_branch["index"])
    t_direction_buses = Vector{Int}()
    closest_t_bus = data["bus"][string(target_branch["t_bus"])]
    recursive_connected_nodes(data, target_branch, closest_t_bus, t_direction_buses)
    # println(t_direction_buses)
    # println()

    # Find the root node
    root_bus_id = get_root_bus(data)

    # Check both sides of the branch for the root node. Then do a depth first search
    # to find only the nodes that are upstream
    upstream_nodes = []
    if root_bus_id in f_direction_buses
        downstream_nodes = t_direction_buses
        dfs_to_root(data, target_branch, closest_f_bus, upstream_nodes, root_bus_id)
    else
        downstream_nodes = f_direction_buses
        dfs_to_root(data, target_branch, closest_t_bus, upstream_nodes, root_bus_id)
    end

    target_branch["upstream_nodes"] = upstream_nodes
    target_branch["downstream_nodes"] = downstream_nodes

    # Also set the nearest upstream and downstream node for a branch
    target_branch["upstream_node"] = upstream_nodes[1]
    target_branch["downstream_node"] = downstream_nodes[1]

    # Iterate through each branch, and check if it's upstream or downstream
    downstream_branches = Vector{Int}()
    upstream_branches = Vector{Int}()
    for (l, branch) in data["branch"]
        # Don't include the current branch in the set
        if l == target_branch["index"]
            continue
        end
        # If the branch connects to any downstream node, the branch must be downstream
        if branch["f_bus"] in downstream_nodes || branch["t_bus"] in downstream_nodes
            push!(downstream_branches, parse(Int, l))
        end
        # If the branch connects 1 upstream node to another upstream node, the branch is in
        # the path to the root node
        if branch["f_bus"] in upstream_nodes && branch["t_bus"] in upstream_nodes
            push!(upstream_branches, parse(Int, l))
        end        
    end

    target_branch["upstream_branches"] = upstream_branches
    target_branch["downstream_branches"] = downstream_branches

end

function create_network_diagram!(data)
    # For each branch, build a mapping of upstream and downstream nodes
    for (i, branch) in data["branch"]
        set_upstream_downstream_nodes_branches!(data, branch)
    end

end

function set_chance_constraint_etas!(data, η_g, η_u, η_f)
    data["η_g"] = η_g
    data["η_u"] = η_u
    data["η_f"] = η_f
end


function set_privacy_parameters!(data, δ, ϵ)
    # Check each branch to determine if there is a load attached.
    # If so, set sigma based on the Pd value of this load.
    load_bus_index = Dict(bus["load_bus"] => l for (l, bus) in data["load"])
    for (i, branch) in data["branch"]
        if branch["downstream_node"] in keys(load_bus_index)
            β = 0.1 * data["load"][load_bus_index[branch["downstream_node"]]]["pd"] # Ref: DP_CC_OPF.jl line 44
            branch["σ"] = β * sqrt(2 * log(1.25 / δ)) / ϵ # Ref: DP_CC_OPF.jl line 45
        else
            branch["σ"] = 0
        end
    end
end


function set_power_factor!(data, tanϕ)
    data["tanϕ"] = tanϕ
end
