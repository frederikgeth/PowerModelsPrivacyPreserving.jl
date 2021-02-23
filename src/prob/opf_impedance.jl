
""
function run_opf_variable_impedance_loss(file, optimizer; kwargs...)
    return run_opf_variable_impedance_loss(file, _PM.ACPPowerModel, optimizer; kwargs...)
end

""
function run_opf_variable_impedance_loss(file, model_type::Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, build_opf_variable_impedance_loss; kwargs...)
end

"This is our new model in accordance with Algorithm 1 of the paper"
function build_opf_variable_impedance_loss(pm::_PM.AbstractPowerModel)
    # Comments reference slide 42 on installfest pdf
    _PM.variable_bus_voltage(pm) # Variable in V_i in model 1 -> Constraint 1.3
    _PM.variable_gen_power(pm) # Variable S_i in model 1 -> Constraint 1.5
    _PM.variable_branch_power(pm) # Implicit
    # _PM.variable_dcline_flow(pm)
    variable_admittance(pm) # s4, s5 set upper and lower bounds of g, b


    minimum_impedance_distance(pm) # Our new objective


    constraint_loss_faithfulness(pm) # s2
    _PM.constraint_model_voltage(pm) # Implicit

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i) # Implicit
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i) # Does this reference constraint_kcl_shunt ie Constraint 1.7?
    end

    for i in _PM.ids(pm, :branch)
        constraint_ohms_from_variable_impedance(pm, i) # Constraint s3, s4, 1.8
        constraint_ohms_to_variable_impedance(pm, i) # Constraint s3, s4, 1.8

        _PM.constraint_voltage_angle_difference(pm, i) # Constraint 1.4

        _PM.constraint_thermal_limit_from(pm, i) # Constraint 1.6
        _PM.constraint_thermal_limit_to(pm, i) # Constraint 1.6
    end

    # for i in _PM.ids(pm, :dcline)
    #     _PM.constraint_dcline(pm, i)
    # end
end

""
function run_opf_variable_impedance_cost(file, optimizer; kwargs...)
    return run_opf_variable_impedance_cost(file, _PM.ACPPowerModel, optimizer; kwargs...)
end

""
function run_opf_variable_impedance_cost(file, model_type::Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, build_opf_variable_impedance_cost; kwargs...)
end

"This is our new model in accordance with Algorithm 1 of the paper"
function build_opf_variable_impedance_cost(pm::_PM.AbstractPowerModel)
    # Comments reference slide 42 on installfest pdf
    _PM.variable_bus_voltage(pm) # Variable in V_i in model 1 -> Constraint 1.3
    _PM.variable_gen_power(pm) # Variable S_i in model 1 -> Constraint 1.5
    _PM.variable_branch_power(pm) # Implicit
    # _PM.variable_dcline_flow(pm)
    variable_admittance(pm) # s4, s5 set upper and lower bounds of g, b
    variable_fuel_cost(pm)

    minimum_impedance_distance(pm) # Our new objective


    constraint_fuel_cost_quadratic(pm)
    constraint_cost_faithfulness(pm) # s2

    _PM.constraint_model_voltage(pm) # Implicit

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i) # Implicit
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i) # Does this reference constraint_kcl_shunt ie Constraint 1.7?
    end

    for i in _PM.ids(pm, :branch)
        constraint_ohms_from_variable_impedance(pm, i) # Constraint s3, s4, 1.8
        constraint_ohms_to_variable_impedance(pm, i) # Constraint s3, s4, 1.8

        _PM.constraint_voltage_angle_difference(pm, i) # Constraint 1.4

        _PM.constraint_thermal_limit_from(pm, i) # Constraint 1.6
        _PM.constraint_thermal_limit_to(pm, i) # Constraint 1.6
    end

    # for i in _PM.ids(pm, :dcline)
    #     _PM.constraint_dcline(pm, i)
    # end
end
