
""
function constraint_ohms_from_variable_impedance(pm::PMs.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    branch = PMs.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PMs.calc_branch_y(branch)
    tr, ti = PMs.calc_branch_t(branch)
    g_fr = branch["g_fr"]
    b_fr = branch["b_fr"]
    tm = branch["tap"]

    constraint_ohms_from_variable_impedance(pm, nw, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr, tr, ti, tm)
end


""
function constraint_ohms_to_variable_impedance(pm::PMs.AbstractPowerModel, i::Int; nw::Int=pm.cnw)
    branch = PMs.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PMs.calc_branch_y(branch)
    tr, ti = PMs.calc_branch_t(branch)
    g_to = branch["g_to"]
    b_to = branch["b_to"]
    tm = branch["tap"]

    constraint_ohms_to_variable_impedance(pm, nw, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to, tr, ti, tm)
end


""
function constraint_loss_faithfulness(pm::PMs.AbstractPowerModel; nw::Int=pm.cnw)
    loss = PMs.ref(pm, nw, :loss)

    constraint_loss_faithfulness(pm, nw, loss["value"], loss["beta"])
end


""
function constraint_cost_faithfulness(pm::PMs.AbstractPowerModel; nw::Int=pm.cnw)
    cost = PMs.ref(pm, nw, :cost)

    constraint_cost_faithfulness(pm, nw, cost["value"], cost["beta"])
end
