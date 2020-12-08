
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
    constraint_alpha_summation(pm, i, branch_i["upstream_nodes"], branch_i["downstream_nodes"])
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
        # println(branch)
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


function get_signed_alpha(pm, α, k, l; nw::Int=pm.cnw)
    branch_dict = _PM.ref(pm, nw, :branch, l)
    if k in branch_dict["upstream_nodes"]
        return α[k, l]
    elseif k in branch_dict["downstream_nodes"]
        return -α[k, l]
    else
        return 0
    end
end


""
function constraint_voltage_bounds_cc(pm::_PM.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    # TODO: Separate into constraint.jl
    # Grab our variables from the model
    η_u = _PM.ref(pm, nw, :η_u)
    tanϕ = _PM.ref(pm, nw, :tanϕ)
    α = _PM.var(pm, nw, :α)
    branch_i = _PM.ref(pm, nw, :branch, i)
    
    # Grab the voltage information from the next downstream node
    downstream_node = _PM.ref(pm, nw, :bus, branch_i["downstream_node"])
    u = _PM.var(pm, nw, :w, downstream_node["index"])
    vmax = downstream_node["vmax"]
    vmin = downstream_node["vmin"]
    umax = vmax^2
    umin = vmin^2

    # Helper function to handle the inverse cdf
    Φ(x) = Distributions.quantile(Distributions.Normal(0, 1), x)
    # Φ(x) = -sqrt(2)/2 * log(2*(1-x))

    L = size(α, 2)

    lhs_vector = []
    for l in 1:L
        lhs_summation = 0
        # Don't calculate for any branch with no sigma value
        σ = _PM.ref(pm, nw, :branch, l)["σ"]
        if σ == 0
            continue
        end
        for j in branch_i["upstream_branches"]
            branch_j = _PM.ref(pm, nw, :branch, j)
            r = branch_j["br_r"]
            x = branch_j["br_x"]

            # Declare the LHS side of Eq (4e) and (4f)
            lhs_summation +=  (
                r * (sum(get_signed_alpha(pm, α, k, l) for k in branch_j["downstream_nodes"])) +
                x * tanϕ * (sum(get_signed_alpha(pm, α, k, l) for k in branch_j["downstream_nodes"]))          
            ) * Φ(1 - η_u) * σ
        end
        push!(lhs_vector, lhs_summation)

    end
    # Eq (4e)
    u_max_arr = vcat(0.5 * (umax - u), lhs_vector)
    JuMP.@constraint(pm.model, u_max_arr in JuMP.SecondOrderCone())
    
    # Eq (4f)
    u_min_arr = vcat(0.5 * (u - umin), lhs_vector)
    JuMP.@constraint(pm.model, u_min_arr in JuMP.SecondOrderCone())
end


function constraint_flow_limits_cc(pm::_PM.AbstractPowerModel, l::Int; nw::Int=pm.cnw)
    # Grab our variables from the model
    η_f = _PM.ref(pm, nw, :η_f)
    tanϕ = _PM.ref(pm, nw, :tanϕ)
    α = _PM.var(pm, nw, :α)
    branch_l = _PM.ref(pm, nw, :branch, l)
    p = _PM.var(pm, nw, :p, (l, branch_l["t_bus"], branch_l["f_bus"])) # active power
    q = _PM.var(pm, nw, :q, (l, branch_l["t_bus"], branch_l["f_bus"])) # reactive power
    f_max = branch_l["rate_a"]
    σ = branch_l["σ"]

    # Grab the inner polygon coefficients
    C = _PM.ref(pm, nw, :C)
    α_f = _PM.ref(pm, nw, :α_f)
    β_f = _PM.ref(pm, nw, :β_f)
    δ_f = _PM.ref(pm, nw, :δ_f)

    # Grab the relevant nodes
    downstream_node_ids = branch_l["downstream_nodes"]

    # Helper function to handle the inverse cdf
    Φ(x) = Distributions.quantile(Distributions.Normal(0, 1), x)
    # Φ(x) = -sqrt(2)/2 * log(2*(1-x))

    L = size(α, 2)
    for c in 1:C 
        lhs_vector = []
        for j in 1:L
            # Don't calculate for any branch with no sigma value
            σ = _PM.ref(pm, nw, :branch, j)["σ"]
            if σ == 0
                continue
            end
            tmp = sum(get_signed_alpha(pm, α, n, j) for n in downstream_node_ids)
            lhs = (α_f[c] * tmp + β_f[c] * tanϕ * tmp) * Φ(1 - η_f) * σ
            push!(lhs_vector, lhs)
        end

        # Eq (4g)
        expr = vcat(-α_f[c] * p -  β_f[c] * q - δ_f[c] * f_max, lhs_vector)
        JuMP.@constraint(pm.model, expr in JuMP.SecondOrderCone())
    end
end