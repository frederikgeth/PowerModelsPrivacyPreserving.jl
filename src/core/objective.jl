"This function defines an objective to be the minimum active power losses.
It was being used by Fred's function but I don't think we want to be using it
for Algorithm 1"
function minimum_active_losses(pm::_PM.AbstractPowerModel)
    arcs_from = _PM.ref(pm, :arcs_from)
    p = _PM.var(pm, :p)


    JuMP.@objective(pm.model, Min, sum(p[(l,i,j)] + p[(l,j,i)] for (l,i,j) in arcs_from))
end

"This function defines an objective to be the minimum reactive power losses.
It was being used by Fred's function but I don't think we want to be using it
for Algorithm 1"
function minimum_reactive_losses(pm::_PM.AbstractPowerModel)
    arcs_from = _PM.ref(pm, :arcs_from)
    q = _PM.var(pm, :q)


    JuMP.@objective(pm.model, Min, sum(q[(l,i,j)] + q[(l,j,i)] for (l,i,j) in arcs_from))
end


"This function sets the objective s1 to minimize the distance the post-processed vector is from the privacy-preserved vector"
function minimum_impedance_distance(pm::_PM.AbstractPowerModel)
    branch_ids = _PM.ids(pm, :branch)
    branches = _PM.ref(pm, :branch)

    g = _PM.var(pm, :g)
    b = _PM.var(pm, :b)
    g_shunt = _PM.var(pm, :g_shunt)
    b_shunt = _PM.var(pm, :b_shunt)

    JuMP.@objective(pm.model, Min,
    sum(
    (g[l] - branches[l]["g_obj"])^2
    + (g_shunt[l] - branches[l]["g_shunt_obj"])^2
    + (b[l] - branches[l]["b_obj"])^2
    + (b_shunt[l] - branches[l]["b_shunt_obj"])^2
    for l in branch_ids))
end

"Supporting only quadratic cost functions for generators breaks compatibility with Matpower to some extent"
function objective_min_fuel_cost_quadratic(pm::_PM.AbstractPowerModel; report::Bool=true)
    gen_cost = Dict()
    for (n, nw_ref) in _PM.nws(pm)
        for (i,gen) in nw_ref[:gen]
            pg = sum( _PM.var(pm, n, :pg, i)[c] for c in _PM.conductor_ids(pm, n) )

            if length(gen["cost"]) == 1
                gen_cost[(n,i)] = gen["cost"][1]
            elseif length(gen["cost"]) == 2
                gen_cost[(n,i)] = gen["cost"][1]*pg + gen["cost"][2]
            elseif length(gen["cost"]) == 3
                gen_cost[(n,i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
            else
                gen_cost[(n,i)] = 0.0
            end
        end
    end

    return JuMP.@objective(pm.model, Min,
        sum(
            sum( gen_cost[(n,i)] for (i,gen) in nw_ref[:gen] )
        for (n, nw_ref) in _PM.nws(pm))
    )
end
