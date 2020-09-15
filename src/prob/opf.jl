
""
function run_ac_opf_cost(file, optimizer; kwargs...)
    return run_ac_opf_cost(file, _PM.ACPPowerModel, optimizer; kwargs...)
end

""
function run_ac_opf_cost(file, model_type::Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, build_opf_cost; kwargs...)
end

"This is the canonical minimum generation cost minimization problem (quadratic)"
function build_opf_cost(pm::_PM.AbstractPowerModel)
    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    # _PM.variable_dcline_flow(pm)

    objective_min_fuel_cost_quadratic(pm)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)

        _PM.constraint_voltage_angle_difference(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    # for i in _PM.ids(pm, :dcline)
    #     _PM.constraint_dcline(pm, i)
    # end
end

""
function run_ac_opf_loss(file, optimizer; kwargs...)
    return run_ac_opf_loss(file, _PM.ACPPowerModel, optimizer; kwargs...)
end

""
function run_ac_opf_loss(file, model_type::Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, build_opf_loss; kwargs...)
end

"This is the loss minimization variant
https://lanl-ansi.github.io/PowerModels.jl/stable/specifications/
"
function build_opf_loss(pm::_PM.AbstractPowerModel)
    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    # _PM.variable_dcline_flow(pm)

    minimum_active_losses(pm)
    # minimum_reactive_losses(pm)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)

        _PM.constraint_voltage_angle_difference(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    # for i in _PM.ids(pm, :dcline)
    #     _PM.constraint_dcline(pm, i)
    # end
end
