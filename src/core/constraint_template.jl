
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
    η_g = _PM.ref(pm, nw, :η_g)
    gen = _PM.ref(pm, nw, :gen, i)
    bus = gen["gen_bus"]

    upstream_sigmas = Dict()
    downstream_sigmas = Dict()
    
    for (l, branch) in _PM.ref(pm, nw, :branch)
        if bus ∈ branch["upstream_nodes"]
            upstream_sigmas[l] = branch["σ"] 
        end
        if bus ∈ branch["downstream_nodes"]
            downstream_sigmas[l] = branch["σ"]
        end
    end 
    constraint_gen_bounds_cc(pm, nw, i, gen["pmin"], gen["pmax"], gen["qmin"], gen["qmax"], η_g, upstream_sigmas, downstream_sigmas)
end

