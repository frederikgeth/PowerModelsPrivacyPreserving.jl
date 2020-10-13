
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


function constraint_alpha_summation(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    branch_i = _PM.ref(pm, nw, :branch, i)
    constraint_alpha_summation(pm, nw, i, branch_i["upstream_nodes"], branch_i["downstream_nodes"])
end


""
function constraint_gen_bounds_cc(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    η_g = _PM.ref(pm, nw, :η_g)
    tanϕ = _PM.ref(pm, nw, :tanϕ)
    gen = _PM.ref(pm, nw, :gen, i)
    bus = gen["gen_bus"]

    upstream_sigmas = Dict()
    downstream_sigmas = Dict()
    
    # Check each branch to determine whether the current node is located upstream 
    # or downstream relative to this node. Store the value of sigma for each of these 
    # connected branches.
    for (l, branch) in _PM.ref(pm, nw, :branch)
        if bus ∈ branch["upstream_nodes"]
            upstream_sigmas[l] = branch["σ"] 
        end
        if bus ∈ branch["downstream_nodes"]
            downstream_sigmas[l] = branch["σ"]
        end
    end 
    constraint_gen_bounds_cc(pm, nw, i, gen["pmin"], gen["pmax"], gen["qmin"], gen["qmax"], η_g, tanϕ, upstream_sigmas, downstream_sigmas)
end


"Helper function to retrieve set of downstream nodes"
function get_downstream_node_ids(pm::_PM.AbstractPowerModel, branch_j; nw::Int=pm.cnw)
    return [_PM.ref(pm, nw, :branch, branch_downstream_id)["downstream_node"] for branch_downstream_id in branch_j["downstream_branches"]]
end


""
function constraint_voltage_bounds_cc(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    # TODO: Separate into constraint.jl
    # Grab our variables from the model
    η_u = _PM.ref(pm, nw, :η_u)
    tanϕ = _PM.ref(pm, nw, :tanϕ)
    α = _PM.var(pm, nw, :α)
    branch_i = _PM.ref(pm, nw, :branch, i)
    u = _PM.var(pm, nw, :w, i)
    σ = branch_i["σ"]
    
    # Grab the vmax and vmin from the next downstream node
    downstream_node = _PM.ref(pm, nw, :bus, branch_i["downstream_node"])
    vmax = downstream_node["vmax"]
    vmin = downstream_node["vmin"]
    umax = vmax^2
    umin = vmin^2

    # Helper function to handle the inverse cdf
    Φ(x) = Distributions.quantile(Distributions.Normal(0, 1), x)

    summation = []
    for j in branch_i["upstream_branches"]
        branch_j = _PM.ref(pm, nw, :branch, j)
        r = branch_j["br_r"]
        x = branch_j["br_x"]
        downstream_node_id = branch_j["downstream_node"]
        # Declare the LHS side of Eq (4e) and (4f)
        expr =  (
            r * (sum(α[downstream_node_id, :]) + sum(sum(α[next_downstream, :]) for next_downstream in get_downstream_node_ids(pm, branch_j))) + 
            j * (sum(α[downstream_node_id, :] * tanϕ) + sum(sum(α[next_downstream, :] * tanϕ) for next_downstream in get_downstream_node_ids(pm, branch_j)))
        )
        push!(summation, expr)

    end

    # Eq (4e)
    JuMP.@constraint(pm.model, sum((Φ(1 - η_u) * σ * term).^2 for term in summation) <= 0.5 * (umax - u)^2)
    # Eq (4f)
    JuMP.@constraint(pm.model, sum((Φ(1 - η_u) * σ * term).^2 for term in summation) <= 0.5 * (u - umin)^2)

    # constraint_voltage_bounds_cc(pm, nw, i, η_u)
end