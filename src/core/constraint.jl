
"""
Creates Ohms constraints (yt post fix indicates that Y and T values are in rectangular form)
```
p[f_idx] ==  (g+g_fr)/tm*v[f_bus]^2 + (-g*tr+b*ti)/tm^2*(v[f_bus]*v[t_bus]*cos(t[f_bus]-t[t_bus])) + (-b*tr-g*ti)/tm^2*(v[f_bus]*v[t_bus]*sin(t[f_bus]-t[t_bus]))
q[f_idx] == -(b+b_fr)/tm*v[f_bus]^2 - (-b*tr-g*ti)/tm^2*(v[f_bus]*v[t_bus]*cos(t[f_bus]-t[t_bus])) + (-g*tr+b*ti)/tm^2*(v[f_bus]*v[t_bus]*sin(t[f_bus]-t[t_bus]))
```
"""
function constraint_ohms_from_variable_impedance(pm::PMs.AbstractACPModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr, tr, ti, tm)
    (l,i,j) = f_idx
    p_fr  = PMs.var(pm, n,  :p, f_idx)
    q_fr  = PMs.var(pm, n,  :q, f_idx)
    vm_fr = PMs.var(pm, n, :vm, f_bus)
    vm_to = PMs.var(pm, n, :vm, t_bus)
    va_fr = PMs.var(pm, n, :va, f_bus)
    va_to = PMs.var(pm, n, :va, t_bus)

    b = PMs.var(pm, n, :b, l)
    g = PMs.var(pm, n, :g, l)    # g = y*r

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
function constraint_ohms_to_variable_impedance(pm::PMs.AbstractACPModel, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to, tr, ti, tm)
    (l,i,j) = f_idx
    p_to  = PMs.var(pm, n,  :p, t_idx)
    q_to  = PMs.var(pm, n,  :q, t_idx)
    vm_fr = PMs.var(pm, n, :vm, f_bus)
    vm_to = PMs.var(pm, n, :vm, t_bus)
    va_fr = PMs.var(pm, n, :va, f_bus)
    va_to = PMs.var(pm, n, :va, t_bus)

    # r = g/b
    b = PMs.var(pm, n, :b, l)
    g = PMs.var(pm, n, :g, l)
    # g = y*r

    JuMP.@NLconstraint(pm.model, p_to ==  (g+g_to)*vm_to^2
    + (-g*tr-b*ti)/tm^2*(vm_to*vm_fr*cos(va_to-va_fr))
    + (-b*tr+g*ti)/tm^2*(vm_to*vm_fr*sin(va_to-va_fr)) )
    JuMP.@NLconstraint(pm.model, q_to == -(b+b_to)*vm_to^2
    - (-b*tr+g*ti)/tm^2*(vm_to*vm_fr*cos(va_to-va_fr))
    + (-g*tr-b*ti)/tm^2*(vm_to*vm_fr*sin(va_to-va_fr)) )
end
