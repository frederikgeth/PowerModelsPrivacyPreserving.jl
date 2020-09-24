
"""
Creates Ohms constraints (yt post fix indicates that Y and T values are in rectangular form)
```
p[f_idx] ==  (g+g_fr)/tm*v[f_bus]^2 + (-g*tr+b*ti)/tm^2*(v[f_bus]*v[t_bus]*cos(t[f_bus]-t[t_bus])) + (-b*tr-g*ti)/tm^2*(v[f_bus]*v[t_bus]*sin(t[f_bus]-t[t_bus]))
q[f_idx] == -(b+b_fr)/tm*v[f_bus]^2 - (-b*tr-g*ti)/tm^2*(v[f_bus]*v[t_bus]*cos(t[f_bus]-t[t_bus])) + (-g*tr+b*ti)/tm^2*(v[f_bus]*v[t_bus]*sin(t[f_bus]-t[t_bus]))
```
"""
function constraint_ohms_from_variable_impedance(pm::_PM.AbstractACPModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr, tr, ti, tm)
    (l,i,j) = f_idx
    p_fr  = _PM.var(pm, n,  :p, f_idx)
    q_fr  = _PM.var(pm, n,  :q, f_idx)
    vm_fr = _PM.var(pm, n, :vm, f_bus)
    vm_to = _PM.var(pm, n, :vm, t_bus)
    va_fr = _PM.var(pm, n, :va, f_bus)
    va_to = _PM.var(pm, n, :va, t_bus)

    b = _PM.var(pm, n, :b, l)
    g = _PM.var(pm, n, :g, l)    # g = y*r
    b_fr = _PM.var(pm, n, :b_shunt, l)
    g_fr = _PM.var(pm, n, :g_shunt, l)

    JuMP.@NLconstraint(pm.model, p_fr ==  (g+g_fr)/tm^2*vm_fr^2
    + (-g*tr+b*ti)/tm^2*(vm_fr*vm_to*cos(va_fr-va_to))
    + (-b*tr-g*ti)/tm^2*(vm_fr*vm_to*sin(va_fr-va_to)) )
    JuMP.@NLconstraint(pm.model, q_fr == -(b+b_fr)/tm^2*vm_fr^2
    - (-b*tr-g*ti)/tm^2*(vm_fr*vm_to*cos(va_fr-va_to))
    + (-g*tr+b*ti)/tm^2*(vm_fr*vm_to*sin(va_fr-va_to)) )
end

"""
Creates Ohms constraints (yt post fix indicates that Y and T values are in rectangular form)
```
p[t_idx] ==  (g+g_to)*v[t_bus]^2 + (-g*tr-b*ti)/tm^2*(v[t_bus]*v[f_bus]*cos(t[t_bus]-t[f_bus])) + (-b*tr+g*ti)/tm^2*(v[t_bus]*v[f_bus]*sin(t[t_bus]-t[f_bus]))
q[t_idx] == -(b+b_to)*v[t_bus]^2 - (-b*tr+g*ti)/tm^2*(v[t_bus]*v[f_bus]*cos(t[f_bus]-t[t_bus])) + (-g*tr-b*ti)/tm^2*(v[t_bus]*v[f_bus]*sin(t[t_bus]-t[f_bus]))
```
"""
function constraint_ohms_to_variable_impedance(pm::_PM.AbstractACPModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to, tr, ti, tm)
    (l,i,j) = f_idx
    p_to  = _PM.var(pm, n,  :p, t_idx)
    q_to  = _PM.var(pm, n,  :q, t_idx)
    vm_fr = _PM.var(pm, n, :vm, f_bus)
    vm_to = _PM.var(pm, n, :vm, t_bus)
    va_fr = _PM.var(pm, n, :va, f_bus)
    va_to = _PM.var(pm, n, :va, t_bus)

    # r = g/b
    b = _PM.var(pm, n, :b, l)
    g = _PM.var(pm, n, :g, l)
    b_to = _PM.var(pm, n, :b_shunt, l)
    g_to = _PM.var(pm, n, :g_shunt, l)
    # g = y*r

    JuMP.@NLconstraint(pm.model, p_to ==  (g+g_to)*vm_to^2
    + (-g*tr-b*ti)/tm^2*(vm_to*vm_fr*cos(va_to-va_fr))
    + (-b*tr+g*ti)/tm^2*(vm_to*vm_fr*sin(va_to-va_fr)) )
    JuMP.@NLconstraint(pm.model, q_to == -(b+b_to)*vm_to^2
    - (-b*tr+g*ti)/tm^2*(vm_to*vm_fr*cos(va_to-va_fr))
    + (-g*tr-b*ti)/tm^2*(vm_to*vm_fr*sin(va_to-va_fr)) )
end

"""
Defines the faithfullness in terms of grid losses
|actual_loss - reference_loss|/(reference_loss) <= beta
we split this in two constraints to deal with the absolute value
|x| <= y iff x <=y and -x<=y
"""
function constraint_loss_faithfulness(pm::_PM.AbstractPowerModel, n::Int, ref_loss, beta)
    arcs_from = _PM.ref(pm, :arcs_from)
    p = _PM.var(pm, :p)

    loss = sum(p[(l,i,j)] + p[(l,j,i)] for (l,i,j) in arcs_from)

    JuMP.@constraint(pm.model, (loss - ref_loss)/(ref_loss) <= beta)
    JuMP.@constraint(pm.model, (ref_loss - loss)/(ref_loss) <= beta)
end


function constraint_cost_faithfulness(pm::_PM.AbstractPowerModel, n::Int, ref_cost, beta)
    cost = _PM.var(pm, :cost)

    JuMP.@constraint(pm.model, (cost - ref_cost)/(ref_cost) <= beta)
    JuMP.@constraint(pm.model, (ref_cost - cost)/(ref_cost) <= beta)
end


"Supporting only quadratic cost functions for generators breaks compatibility with Matpower to some extent"
function constraint_fuel_cost_quadratic(pm::_PM.AbstractPowerModel)
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

    cost = _PM.var(pm, :cost)
    JuMP.@constraint(pm.model, cost ==
        sum(
            sum( gen_cost[(n,i)] for (i,gen) in nw_ref[:gen] )
        for (n, nw_ref) in _PM.nws(pm))
            )
end

function constraint_gen_bounds_cc(pm::_PM.AbstractPowerModel, n::Int, i, pmin, pmax, qmin, qmax, eta)
    pg = _PM.var(pm, n, :pg, i)
    qg = _PM.var(pm, n, :qg, i)
    d = Distributions.Normal()
    z = Distributions.quantile(d,eta)

    # JuMP.@constraint(pm.model, (cost - ref_cost)/(ref_cost) <= beta)
end


"""
Defines voltage drop over a branch, linking from and to side voltage magnitude
"""
function constraint_voltage_magnitude_difference_cc(pm::AbstractBFAModel, n::Int, i, f_bus, t_bus, f_idx, t_idx, r, x, g_sh_fr, b_sh_fr, tm)
    p_fr = var(pm, n, :p, f_idx)
    q_fr = var(pm, n, :q, f_idx)
    w_fr = var(pm, n, :w, f_bus)
    w_to = var(pm, n, :w, t_bus)

    JuMP.@constraint(pm.model, (w_fr/tm^2) - w_to ==  2*(r*p_fr + x*q_fr))
end
