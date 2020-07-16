"This script will run the perturbation function on each case of increasing size
(determined by the parameter num_cases) and attempt to solve. If a solution times
out (at 3000 iterations) the result is written to the unsolved/ folder. Otherwise,
the output of each run is fed to result_dict, which contains tuples indicating the
(result_pert_loss, result_pert_cost)."

using Ipopt
using PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random
using JuMP

const PMs = PowerModels
const PMPP = PowerModelsPrivacyPreserving

"https://stackoverflow.com/questions/48195775/how-to-pretty-print-nested-dicts-in-julia
Adapted by EV to write to file"
function pretty_print_to_file(io, d::Dict, pre=1)
    for (k,v) in d
        if typeof(v) <: Dict
            s = "$(repr(k)) => "
            write(io, join(fill(" ", pre)) * s * "\n")
            pretty_print_to_file(io, v, pre+1+length(s))
        else
            write(io, join(fill(" ", pre)) * "$(repr(k)) => $(repr(v))" * "\n")
        end
    end
    nothing
end

function check_dataset_perturbation(test_directory, output_directory, filename, α, ϵ, λ)
    # ipopt = Ipopt.Optimizer
    optimizer = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "max_cpu_time" => 600.0)
    data_unpert = parse_file(string(test_directory, filename))
    data_min_loss = deepcopy(data_unpert)
    data_min_cost = deepcopy(data_unpert)

    "this is the canonical OPF problem with generation cost minimization"
    result_unpert_cost = PMPP.run_ac_opf_cost(data_unpert, optimizer)
    PMPP.calculate_losses!(result_unpert_cost, data_unpert)
    "store faithfulness info"
    data_min_cost["cost"] = Dict()
    data_min_cost["cost"]["value"] = result_unpert_cost["objective"]
    data_min_cost["cost"]["beta"] = 1

    "this variant of the OPF problem minimizes grid losses instead of generation cost"
    result_unpert_loss = PMPP.run_ac_opf_loss(data_unpert, optimizer)
    PMPP.calculate_losses!(result_unpert_loss, data_unpert)
    "store faithfulness info"
    data_min_loss["loss"] = Dict()
    data_min_loss["loss"]["value"] = result_unpert_loss["totalloss"]
    data_min_loss["loss"]["beta"] = 1

    # Add impedance perturbation to both data dictionaries.
    data_pert_min_loss = PMPP.create_impedance_perturbation(data_min_loss, α, ϵ, λ)
    data_pert_min_cost = PMPP.create_impedance_perturbation(data_min_cost, α, ϵ, λ)

    # 1) Run solver for perturbed loss
    result_pert_loss = PMPP.run_opf_variable_impedance_loss(data_pert_min_loss, optimizer)
    PMPP.calculate_losses!(result_pert_loss, data_pert_min_loss)
    PMPP.overwrite_impedances_in_data!(result_pert_loss, data_pert_min_loss)
    # @assert result_pert_loss["termination_status"] == PMs.LOCALLY_SOLVED

    # Handle writing results to file based on success criteria
    if (result_pert_loss["termination_status"] == PMs.LOCALLY_SOLVED)
        result_directory = "pert_min_loss/"
    elseif (result_pert_loss["termination_status"] == PMs.TIME_LIMIT)
        result_directory = "timed_out_min_loss/"
    else
        result_directory = "failed_min_loss/"
    end
    open(output_directory * result_directory * filename[1:length(filename) - 2] * "_result.txt", "w") do io
        pretty_print_to_file(io, result_pert_loss)
    end
    open(output_directory * result_directory * filename[1:length(filename) - 2] * "_data.m", "w") do io
        PMs.export_matpower(io, data_pert_min_loss)
    end

    # 2) Run solver for perturbed cost
    result_pert_cost = PMPP.run_opf_variable_impedance_cost(data_pert_min_cost, optimizer)
    PMPP.calculate_losses!(result_pert_cost, data_pert_min_cost)
    PMPP.overwrite_impedances_in_data!(result_pert_cost, data_pert_min_cost)
    # @assert result_pert_cost["termination_status"] == PMs.LOCALLY_SOLVED

    # Handle writing results to file based on success criteria
    if (result_pert_cost["termination_status"] == PMs.LOCALLY_SOLVED)
        result_directory = "pert_min_cost/"
    elseif (result_pert_cost["termination_status"] == PMs.TIME_LIMIT)
        result_directory = "timed_out_min_cost/"
    else
        result_directory = "failed_min_cost/"
    end
    open(output_directory * result_directory * filename[1:length(filename) - 2] * "_result.txt", "w") do io
        pretty_print_to_file(io, result_pert_loss)
    end
    open(output_directory * result_directory * filename[1:length(filename) - 2] * "_data.m", "w") do io
        PMs.export_matpower(io, data_pert_min_loss)
    end
end

"Set the variable num_cases to determine how many cases to solve"
num_cases = 40
start_case = 1
start_index = 1

# Make all directories for outputs
test_directory = "test/data/pglib_tests/"
output_directory = "examples/test_perturbation_outputs/"
try
    mkdir(output_directory)
catch y
    println("Output folder already exists, continuing")
end

for run_index = start_index:10
    run_output_directory = output_directory * string(run_index) * "/"
    try
        mkdir(run_output_directory)
    catch y
        println("Iteration folder already exists, continuing")
    end

    try
        mkdir(string(run_output_directory, "pert_min_loss"))
        mkdir(string(run_output_directory, "pert_min_cost"))
        mkdir(string(run_output_directory, "failed_min_loss"))
        mkdir(string(run_output_directory, "failed_min_cost"))
        mkdir(string(run_output_directory, "timed_out_min_loss"))
        mkdir(string(run_output_directory, "timed_out_min_cost"))
    catch y
        println("Output subfolders already exist, continuing")
    end

    # Sort the list of cases by size
    sorted_directory = sort(
        readdir(test_directory),
        by = f -> parse(Int, strip(split(f, "_")[3][5:end], ['w', 'o', 'p', 's']))
    )
    for filename in sorted_directory[start_case: num_cases]
        println("Testing ", filename)
        check_dataset_perturbation(test_directory, run_output_directory, filename, 0.01, 1, 50)
    end
    global start_case = 1
end
