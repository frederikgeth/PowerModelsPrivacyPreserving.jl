
""
function run_ac_opf_variable_impedance(file, optimizer; kwargs...)
    return run_opf_variable_impedance(file, ACPPowerModel, optimizer; kwargs...)
end

""
function run_opf_variable_impedance(file, model_type::Type, optimizer; kwargs...)
    return PMs.run_model(file, model_type, optimizer, build_opf_variable_impedance; kwargs...)
end

"This is our new model in accordance with Algorithm 1 of the paper"
function build_opf_variable_impedance(pm::AbstractPowerModel)
    # Comments reference slide 42 on installfest pdf
    PMs.variable_voltage(pm) # Variable in V_i in model 1 -> Constraint 1.3
    PMs.variable_generation(pm) # Variable S_i in model 1 -> Constraint 1.5
    PMs.variable_branch_flow(pm) # Implicit
    # PMs.variable_dcline_flow(pm)
    variable_admittance(pm) # s4, s5 set upper and lower bounds of g, b

    # PMs.objective_min_fuel_and_flow_cost(pm)
    # minimum_losses(pm)
    minimum_impedance_distance(pm) # Our new objective

    PMs.constraint_model_voltage(pm) # Implicit

    for i in PMs.ids(pm, :ref_buses)
        PMs.constraint_theta_ref(pm, i) # Implicit
    end

    for i in PMs.ids(pm, :bus)
        PMs.constraint_power_balance(pm, i) # Does this reference constraint_kcl_shunt ie Constraint 1.7?
    end

    for i in PMs.ids(pm, :branch)
        constraint_ohms_from_variable_impedance(pm, i) # Constraint s3, s4, 1.8
        constraint_ohms_to_variable_impedance(pm, i) # Constraint s3, s4, 1.8

        PMs.constraint_voltage_angle_difference(pm, i) # Constraint 1.4

        PMs.constraint_thermal_limit_from(pm, i) # Constraint 1.6
        PMs.constraint_thermal_limit_to(pm, i) # Constraint 1.6
    end

    # for i in PMs.ids(pm, :dcline)
    #     PMs.constraint_dcline(pm, i)
    # end
end

function calculate_losses(res)
    for (l, branch) in res["solution"]["branch"]
        branch["ploss"] = branch["pf"] + branch["pt"]
    end
    res["totalloss"] = sum(branch["ploss"] for (l, branch) in res["solution"]["branch"])

    res["totalload"] = sum(load["pd"] for (l, load) in data_unpert["load"])

    res["totalgen"] = sum(gen["pg"] for (l, gen) in res["solution"]["gen"])
end
