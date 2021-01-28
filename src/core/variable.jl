"variable: `g[l] + im*b[l]` for `(l,i,j)` in `arcs`"
function variable_admittance(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw, bounded::Bool=true, report::Bool=true)
    g = _PM.var(pm, nw)[:g] = JuMP.@variable(pm.model,
        [ l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_g",
        # start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "y_start")
    )
    b = _PM.var(pm, nw)[:b] = JuMP.@variable(pm.model,
        [ l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_b",
        # start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "y_start")
    )
    g_shunt = _PM.var(pm, nw)[:g_shunt] = JuMP.@variable(pm.model,
        [ l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_g_shunt",
        # start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "y_start")
    )
    b_shunt = _PM.var(pm, nw)[:b_shunt] = JuMP.@variable(pm.model,
        [ l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_b_shunt",
        # start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "y_start")
    )
    # Limit the upper and lower bound of each g,b for model constraint s4 and s5
    for (l,branch) in _PM.ref(pm, nw, :branch)
        JuMP.set_lower_bound(g[l], _PM.ref(pm, nw, :g_lb))
        JuMP.set_upper_bound(g[l], _PM.ref(pm, nw, :g_ub))
        JuMP.set_lower_bound(b[l], _PM.ref(pm, nw, :b_lb))
        JuMP.set_upper_bound(b[l],_PM.ref(pm, nw, :b_ub))
        JuMP.set_lower_bound(g_shunt[l], _PM.ref(pm, nw, :g_lb_shunt))
        JuMP.set_upper_bound(g_shunt[l], _PM.ref(pm, nw, :g_ub_shunt))
        JuMP.set_lower_bound(b_shunt[l], _PM.ref(pm, nw, :b_lb_shunt))
        JuMP.set_upper_bound(b_shunt[l],_PM.ref(pm, nw, :b_ub_shunt))
    end

    report && _IM.sol_component_value(pm, nw, :branch, :g, _PM.ids(pm, nw, :branch), g)
    report && _IM.sol_component_value(pm, nw, :branch, :b, _PM.ids(pm, nw, :branch), b)
    report && _IM.sol_component_value(pm, nw, :branch, :g_shunt, _PM.ids(pm, nw, :branch), g_shunt)
    report && _IM.sol_component_value(pm, nw, :branch, :b_shunt, _PM.ids(pm, nw, :branch), b_shunt)
end

function variable_fuel_cost(pm::_PM.AbstractPowerModel, report::Bool=true)
    # variable to store generation cost
    cost = _PM.var(pm)[:cost] = JuMP.@variable(pm.model, cost)
end


"variable: `α[n,l]` for `n` in `bus`, l in `branch`"
function variable_alpha_power_response(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw, report::Bool=true)
    # Declare the alpha matrix, and initialize each value as 0
    α = _PM.var(pm, nw)[:α] = JuMP.@variable(
        pm.model,
        [n in _PM.ids(pm, nw, :bus), l in _PM.ids(pm, nw, :branch)], 
        base_name="α",
        start=0,
        lower_bound=0,
        upper_bound=1
    )

end

