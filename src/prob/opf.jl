
""
function run_ac_opf_cost(file, optimizer; kwargs...)
    return run_ac_opf_cost(file, PMs.ACPPowerModel, optimizer; kwargs...)
end

""
function run_ac_opf_cost(file, model_type::Type, optimizer; kwargs...)
    return PMs.run_model(file, model_type, optimizer, build_opf_cost; kwargs...)
end

"This is the canonical minimum generation cost minimization problem (quadratic)"
function build_opf_cost(pm::PMs.AbstractPowerModel)
    PMs.variable_voltage(pm)
    PMs.variable_generation(pm)
    PMs.variable_branch_flow(pm)
    # PMs.variable_dcline_flow(pm)

    objective_min_fuel_cost_quadratic(pm)

    PMs.constraint_model_voltage(pm)

    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i)
    end

    for i in PMs.ids(pm, :bus)
        PMs.constraint_power_balance(pm, i)
    end

    for i in PMs.ids(pm, :branch)
        PMs.constraint_ohms_yt_from(pm, i)
        PMs.constraint_ohms_yt_to(pm, i)

        PMs.constraint_voltage_angle_difference(pm, i)

        PMs.constraint_thermal_limit_from(pm, i)
        PMs.constraint_thermal_limit_to(pm, i)
    end

    # for i in PMs.ids(pm, :dcline)
    #     PMs.constraint_dcline(pm, i)
    # end
end

""
function run_ac_opf_loss(file, optimizer; kwargs...)
    return run_ac_opf_loss(file, PMs.ACPPowerModel, optimizer; kwargs...)
end

""
function run_ac_opf_loss(file, model_type::Type, optimizer; kwargs...)
    return PMs.run_model(file, model_type, optimizer, build_opf_loss; kwargs...)
end

"This is the loss minimization variant
https://lanl-ansi.github.io/PowerModels.jl/stable/specifications/
"
function build_opf_loss(pm::PMs.AbstractPowerModel)
    PMs.variable_voltage(pm)
    PMs.variable_generation(pm)
    PMs.variable_branch_flow(pm)
    # PMs.variable_dcline_flow(pm)

    minimum_active_losses(pm)
    # minimum_reactive_losses(pm)

    PMs.constraint_model_voltage(pm)

    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i)
    end

    for i in PMs.ids(pm, :bus)
        PMs.constraint_power_balance(pm, i)
    end

    for i in PMs.ids(pm, :branch)
        PMs.constraint_ohms_yt_from(pm, i)
        PMs.constraint_ohms_yt_to(pm, i)

        PMs.constraint_voltage_angle_difference(pm, i)

        PMs.constraint_thermal_limit_from(pm, i)
        PMs.constraint_thermal_limit_to(pm, i)
    end

    # for i in PMs.ids(pm, :dcline)
    #     PMs.constraint_dcline(pm, i)
    # end
end
