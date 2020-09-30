"""Comments referencing Differential Private Optimal Power Flow for Distribution
Grids - Dvorkin et al"""

""
function run_opf_bf_dvorkin(file, model_type::Type{T}, optimizer; kwargs...) where T <: _PM.AbstractBFModel
    return _PM.run_model(file, model_type, optimizer, build_opf_bf_dvorkin; kwargs...)
end


""
function build_opf_bf_dvorkin(pm::_PM.AbstractPowerModel)
    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_branch_current(pm)
    # variable_dcline_power(pm)

    _PM.objective_min_fuel_and_flow_cost(pm)

    _PM.constraint_model_current(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_power_losses(pm, i)
        _PM.constraint_voltage_magnitude_difference(pm, i)

        _PM.constraint_voltage_angle_difference(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    # We aren't using dcline for our problem so commented out
    # for i in ids(pm, :dcline)
    #     constraint_dcline_power_losses(pm, i)
    # end
end


""
function run_opf_bf_dvorkin_cc(file, model_type::Type{T}, optimizer; kwargs...) where T <: _PM.AbstractBFModel
    return _PM.run_model(file, model_type, optimizer, build_opf_bf_dvorkin_cc; kwargs...)
end


""
function build_opf_bf_dvorkin_cc(pm::_PM.AbstractPowerModel)
    _PM.variable_bus_voltage(pm, bounded=false)
    _PM.variable_gen_power(pm, bounded=true)
    _PM.variable_branch_power(pm, bounded=false)
    _PM.variable_branch_current(pm)
    variable_gen_power_response(pm)
    # variable_dcline_power(pm)

    _PM.objective_min_fuel_and_flow_cost(pm)

    _PM.constraint_model_current(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    # # Set (2b)
    # for i in _PM.ids(pm, :branch)
    #     constraint_balancing_condition(pm, i)
    # end
    #
    # # Set (4c) and (4d)
    # for i in _PM.ids(pm, :gen)
    #     constraint_gen_bounds_cc(pm, i)
    # end


    for i in _PM.ids(pm, :branch)
        _PM.constraint_power_losses(pm, i)
        _PM.constraint_voltage_magnitude_difference(pm, i)

        # _PM.constraint_voltage_angle_difference(pm, i)

        # _PM.constraint_thermal_limit_from(pm, i)
        # _PM.constraint_thermal_limit_to(pm, i)
    end

    # We aren't using dcline for our problem so commented out
    # for i in ids(pm, :dcline)
    #     constraint_dcline_power_losses(pm, i)
    # end
end
