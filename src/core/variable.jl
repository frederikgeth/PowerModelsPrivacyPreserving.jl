"variable: `g[l] + im*b[l]` for `(l,i,j)` in `arcs`"
function variable_admittance(pm::PMs.AbstractPowerModel; nw::Int=pm.cnw, bounded::Bool=true, report::Bool=true)
    g = PMs.var(pm, nw)[:g] = JuMP.@variable(pm.model,
        [ l in PMs.ids(pm, nw, :branch)], base_name="$(nw)_g",
        # start = PMs.comp_start_value(PMs.ref(pm, nw, :branch, l), "y_start")
    )
    b = PMs.var(pm, nw)[:b] = JuMP.@variable(pm.model,
        [ l in PMs.ids(pm, nw, :branch)], base_name="$(nw)_b",
        # start = PMs.comp_start_value(PMs.ref(pm, nw, :branch, l), "y_start")
    )
    g_shunt = PMs.var(pm, nw)[:g_shunt] = JuMP.@variable(pm.model,
        [ l in PMs.ids(pm, nw, :branch)], base_name="$(nw)_g_shunt",
        # start = PMs.comp_start_value(PMs.ref(pm, nw, :branch, l), "y_start")
    )
    b_shunt = PMs.var(pm, nw)[:b_shunt] = JuMP.@variable(pm.model,
        [ l in PMs.ids(pm, nw, :branch)], base_name="$(nw)_b_shunt",
        # start = PMs.comp_start_value(PMs.ref(pm, nw, :branch, l), "y_start")
    )
    # Limit the upper and lower bound of each g,b for model constraint s4 and s5
    for (l,branch) in PMs.ref(pm, nw, :branch)
        JuMP.set_lower_bound(g[l], PMs.ref(pm, nw, :g_lb))
        JuMP.set_upper_bound(g[l], PMs.ref(pm, nw, :g_ub))
        JuMP.set_lower_bound(b[l], PMs.ref(pm, nw, :b_lb))
        JuMP.set_upper_bound(b[l],PMs.ref(pm, nw, :b_ub))
        JuMP.set_lower_bound(g_shunt[l], PMs.ref(pm, nw, :g_shunt_lb))
        JuMP.set_upper_bound(g_shunt[l], PMs.ref(pm, nw, :g_shunt_ub))
        JuMP.set_lower_bound(b_shunt[l], PMs.ref(pm, nw, :b_shunt_lb))
        JuMP.set_upper_bound(b_shunt[l],PMs.ref(pm, nw, :b_shunt_ub))
    end

    report && PMs.sol_component_value(pm, nw, :branch, :g, PMs.ids(pm, nw, :branch), g)
    report && PMs.sol_component_value(pm, nw, :branch, :b, PMs.ids(pm, nw, :branch), b)
    report && PMs.sol_component_value(pm, nw, :branch, :g_shunt, PMs.ids(pm, nw, :branch), g_shunt)
    report && PMs.sol_component_value(pm, nw, :branch, :b_shunt, PMs.ids(pm, nw, :branch), b_shunt)
end

function variable_fuel_cost(pm::PMs.AbstractPowerModel, report::Bool=true)
    # variable to store generation cost
    cost = PMs.var(pm)[:cost] = JuMP.@variable(pm.model, cost)
end
