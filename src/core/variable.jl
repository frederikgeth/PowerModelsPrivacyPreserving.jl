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


"variable: `alpha[j]` for `j` in `gen`"
function variable_gen_power_response(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw, bounded::Bool=true, report::Bool=true)
    alpha = _PM.var(pm, nw)[:alpha] = JuMP.@variable(pm.model,
        [i in _PM.ids(pm, nw, :gen)], base_name="$(nw)_alpha",
        start = _PM.comp_start_value(_PM.ref(pm, nw, :gen, i), "alpha_start")
    )

    if bounded
        for (i, gen) in _PM.ref(pm, nw, :gen)
            gen["pmax"]==0 ? ub = 0 : ub = 1
            JuMP.set_lower_bound(alpha[i], 0)
            JuMP.set_upper_bound(alpha[i], ub)
        end
    end

    report && _IM.sol_component_value(pm, nw, :gen, :alpha, _PM.ids(pm, nw, :gen), alpha)
end


"variable: `pg[j]` for `j` in `gen`"
function variable_gen_power_including_response(pm::_PM.AbstractPowerModel; nw::Int=pm.cnw, bounded::Bool=true, report::Bool=true)

    pgdict = Dict(gen["pmax"] for (i, gen) in _PM.ref(pm,nw, :gen))

    pg = _PM.var(pm, nw)[:pg]

    report && _IM.sol_component_value(pm, nw, :gen, :alpha, _PM.ids(pm, nw, :gen), alpha)
end
