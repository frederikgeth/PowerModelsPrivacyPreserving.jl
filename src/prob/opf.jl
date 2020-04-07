""
function run_ac_opf_test(file, optimizer; kwargs...)
    return run_opf_test(file, PMs.ACPPowerModel, optimizer; kwargs...)
end

""
function run_opf_test(file, model_type::Type, optimizer; kwargs...)
    return PMs.run_model(file, model_type, optimizer, build_opf_test; kwargs...)
end

"This is the function that Fred has created that implements the existing ACOPF model 1 TODO: Confirm
https://lanl-ansi.github.io/PowerModels.jl/stable/specifications/
EV Modified to set objective to min fuel and flow cost"
function build_opf_test(pm::PMs.AbstractPowerModel)
    PMs.variable_voltage(pm)
    PMs.variable_generation(pm)
    PMs.variable_branch_flow(pm)
    # PMs.variable_dcline_flow(pm)

    PMs.objective_min_fuel_and_flow_cost(pm) # EV: Model 1 uses this
    # minimum_losses(pm)

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
