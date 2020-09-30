
""
function constraint_ohms_from_variable_impedance(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    branch = _PM.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = _PM.calc_branch_y(branch)
    tr, ti = _PM.calc_branch_t(branch)
    g_fr = branch["g_fr"]
    b_fr = branch["b_fr"]
    tm = branch["tap"]

    constraint_ohms_from_variable_impedance(pm, nw, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr, tr, ti, tm)
end


""
function constraint_ohms_to_variable_impedance(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    branch = _PM.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = _PM.calc_branch_y(branch)
    tr, ti = _PM.calc_branch_t(branch)
    g_to = branch["g_to"]
    b_to = branch["b_to"]
    tm = branch["tap"]

    constraint_ohms_to_variable_impedance(pm, nw, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to, tr, ti, tm)
end


""
function constraint_loss_faithfulness(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw)
    loss = _PM.ref(pm, nw, :loss)

    constraint_loss_faithfulness(pm, nw, loss["value"], loss["beta"])
end


""
function constraint_cost_faithfulness(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw)
    cost = _PM.ref(pm, nw, :cost)

    constraint_cost_faithfulness(pm, nw, cost["value"], cost["beta"])
end


""
function constraint_gen_bounds_cc(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    gen = _PM.ref(pm, nw, :gen, i)
    constraint_gen_bounds_cc(pm, nw, i, gen["pmin"], gen["pmax"], gen["qmin"], gen["qmax"], gen["eta"])
end


# "Helper function to accept a node, and return a list of adjacent branches to iterate through"
# function get_adjacent_branches(pm::_PM.AbstractPowerModel, current_bus, target_branch; nw::Int=pm.cnw)
#     adjacent_branches = []
#     for i in _PM.ids(pm, :branch)
#         # Check each branch to see which branches connect to the current node
#         # Don't include the target branch
#         branch = _PM.ref(pm, nw, :branch, i)
#         if (branch["f_bus"] == current_bus["bus_i"] || branch["t_bus"] == current_bus["bus_i"]) && target_branch["index"] != branch["index"]
#             push!(adjacent_branches, branch)
#         end
#     end
#     return adjacent_branches
# end
#
#
# "Helper function to find the root node in a model"
# function get_root_bus(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw)
#     for i in _PM.ids(pm, :bus)
#         bus = _PM.ref(pm, nw, :bus, i)
#         if bus["bus_type"] == 3
#             return i
#         end
#     end
#     return 0
# end
#
#
# "Recursive function to find all nodes on a given side of a branch"
# function recursive_connected_nodes(pm::_PM.AbstractPowerModel, target_branch, current_bus, connected_bus_set; nw::Int=pm.cnw)
#     # If we have already visited this node, return
#     if current_bus["bus_i"] in connected_bus_set
#         return
#     end
#     # We are exploring this node, so add it to the explored set
#     push!(connected_bus_set, current_bus["bus_i"])
#
#     # Loop through each adjacent branch and explore recursively
#     for adjacent_branch in get_adjacent_branches(pm::_PM.AbstractPowerModel, current_bus, target_branch)
#         recursive_connected_nodes(pm::_PM.AbstractPowerModel, target_branch, _PM.ref(pm, nw, :bus, adjacent_branch["t_bus"]), connected_bus_set)
#         recursive_connected_nodes(pm::_PM.AbstractPowerModel, target_branch, _PM.ref(pm, nw, :bus, adjacent_branch["f_bus"]), connected_bus_set)
#     end
#
# end
#
#
# "Depth First Search to find the path from a node to the root node"
# function dfs_to_root(pm::_PM.AbstractPowerModel, target_branch, current_bus, dfs_stack, root_bus_id; nw::Int=pm.cnw)
#     # If we have already visited this node, return
#     if current_bus["bus_i"] in dfs_stack
#         return false
#     end
#     # We are exploring this node, so add it to the explored set
#     push!(dfs_stack, current_bus["bus_i"])
#
#     # If this is the root node, exit DFS
#     if current_bus["bus_i"] == root_bus_id
#         return true
#     end
#
#     # Loop through each adjacent branch and explore recursively
#     # If we find the root node, exit DFS
#     for adjacent_branch in get_adjacent_branches(pm::_PM.AbstractPowerModel, current_bus, target_branch)
#         if dfs_to_root(pm::_PM.AbstractPowerModel, target_branch, _PM.ref(pm, nw, :bus, adjacent_branch["t_bus"]), dfs_stack, root_bus_id)
#             return true
#         end
#         if dfs_to_root(pm::_PM.AbstractPowerModel, target_branch, _PM.ref(pm, nw, :bus, adjacent_branch["f_bus"]), dfs_stack, root_bus_id)
#             return true
#         end
#     end
#     pop!(dfs_stack)
#     return false
#
# end
#
# ""
# function constraint_balancing_condition(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
#     target_branch = _PM.ref(pm, nw, :branch, i)
#
#     # For the given branch, explore all buses to the f side of it
#     println("Looking for f nodes for branch ", i)
#     f_direction_buses = []
#     closest_f_bus = _PM.ref(pm, nw, :bus, target_branch["f_bus"])
#     recursive_connected_nodes(pm, target_branch, closest_f_bus, f_direction_buses)
#     println(f_direction_buses)
#     println()
#
#     # For the given branch, explore all buses to the t side of it
#     println("Looking for t nodes for branch ", i)
#     t_direction_buses = []
#     closest_t_bus = _PM.ref(pm, nw, :bus, target_branch["t_bus"])
#     recursive_connected_nodes(pm, target_branch, closest_t_bus, t_direction_buses)
#     println(t_direction_buses)
#     println()
#
#     # Find the root node
#     root_bus_id = get_root_bus(pm)
#
#     # Check both sides of the branch for the root node. Then do a depth first search
#     # to find only the nodes that are upstream
#     upstream_nodes = []
#     if root_bus_id in f_direction_buses
#         downstream_nodes = t_direction_buses
#         dfs_to_root(pm, target_branch, closest_f_bus, upstream_nodes, root_bus_id)
#     else
#         downstream_nodes = f_direction_buses
#         dfs_to_root(pm, target_branch, closest_t_bus, upstream_nodes, root_bus_id)
#     end
#
#     println("upstream_nodes are ")
#     println(upstream_nodes)
#     println("downstream_nodes are ")
#     println(downstream_nodes)
#
#     println()
#     # set_alpha_balances(pm, target_branch, upstream_nodes, downstream_nodes)
#     target_branch[]
#
# end


# "Declare the alpha matrices α_upstream[N,L] and α_downstream[N,L] for a problem"
# function set_alpha_matrix(pm::_PM.AbstractPowerModel)
#     N = length(_PM.ids(pm, :bus))
#     L = length(_PM.ids(pm, :branch))
#     JuMP.@variable(pm.model, α_upstream[N, L])
#     JuMP.@variable(pm.model, α_downstream[N, L])
# end
#
#
# "For a given branch, set the constraints on the upstream and downstream nodes"
# function set_alpha_balances(pm::_PM.AbstractPowerModel, target_branch, upstream_nodes, downstream_nodes; nw::Int=pm.cnw)
#     α_upstream = JuMP.variable_by_name(pm.model, "α_upstream[1,1]")
#     println(α_upstream)
#     JuMP.@constraint(pm.model, sum(α_upstream[node, target_branch["index"]] for node in upstream_nodes) == 1)
#
#     # α_downstream = _PM.ref(pm, nw, :α_downstream)
#     # JuMP.@constraint(pm.model, sum(α_downstream[node, target_branch["index"]] for node in downstream_nodes) == 1)
#
# end
