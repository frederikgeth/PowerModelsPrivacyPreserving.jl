"This function sets the objective to be the minimum losses. It was being used by
Fred's function but I don't think we want to be using it for Algorithm 1"
function minimum_losses(pm::PMs.AbstractPowerModel)
    arcs_from = PMs.ref(pm, :arcs_from)
    p = PMs.var(pm, :p)


    JuMP.@objective(pm.model, Min, sum(p[(l,i,j)] + p[(l,j,i)] for (l,i,j) in arcs_from))
end


"This function sets the objective s1 to minimize the distance the post-processed vector is from the privacy-preserved vector"
function minimum_impedance_distance(pm::PMs.AbstractPowerModel)
    branch_ids = PMs.ids(pm, :branch)
    branches = PMs.ref(pm, :branch)

    g = PMs.var(pm, :g)
    b = PMs.var(pm, :b)

    JuMP.@objective(pm.model, Min,
    sum(
    (g[l] - branches[l]["g_obj"])^2
    + (b[l] - branches[l]["b_obj"])^2
    for l in branch_ids))
end
