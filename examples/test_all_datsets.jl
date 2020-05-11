"This script will run the perturbation function on each case of increasing size
(determined by the parameter num_cases) and attempt to solve. It includes asserts
to check that the cases are being correctly solved. The output is fed to
result_dict, which contains tuples indicating the
(result_pert_loss, result_pert_cost)."

using Ipopt
using PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random

const PMs = PowerModels
const PMPP = PowerModelsPrivacyPreserving

function check_dataset_perturbation(test_directory, output_directory, filename, α, ϵ, λ)
    ipopt = Ipopt.Optimizer
    data_unpert = parse_file(string(test_directory, filename))
    data_min_loss = deepcopy(data_unpert)
    data_min_cost = deepcopy(data_unpert)

    "this is the canonical OPF problem with generation cost minimization"
    result_unpert_cost = PMPP.run_ac_opf_cost(data_unpert, ipopt)
    PMPP.calculate_losses!(result_unpert_cost, data_unpert)
    "store faithfulness info"
    data_min_cost["cost"] = Dict()
    data_min_cost["cost"]["value"] = result_unpert_cost["objective"]
    data_min_cost["cost"]["beta"] = 1

    "this variant of the OPF problem minimizes grid losses instead of generation cost"
    result_unpert_loss = PMPP.run_ac_opf_loss(data_unpert, ipopt)
    PMPP.calculate_losses!(result_unpert_loss, data_unpert)
    "store faithfulness info"
    data_min_loss["loss"] = Dict()
    data_min_loss["loss"]["value"] = result_unpert_loss["totalloss"]
    data_min_loss["loss"]["beta"] = 1

    # Add impedance perturbation to both data dictionaries.
    data_pert_min_loss = PMPP.create_impedance_perturbation(data_min_loss, α, ϵ, λ)
    data_pert_min_cost = PMPP.create_impedance_perturbation(data_min_cost, α, ϵ, λ)

    result_pert_loss = PMPP.run_opf_variable_impedance_loss(data_pert_min_loss, ipopt)
    PMPP.calculate_losses!(result_pert_loss, data_pert_min_loss)
    @assert result_pert_loss["termination_status"] == PMs.LOCALLY_SOLVED

    result_pert_cost = PMPP.run_opf_variable_impedance_cost(data_pert_min_cost, ipopt)
    PMPP.calculate_losses!(result_pert_cost, data_pert_min_cost)
    @assert result_pert_cost["termination_status"] == PMs.LOCALLY_SOLVED

    # Write perturbed datasets to output file
    println(string(output_directory, "pert_min_loss/", filename))
    open(string(output_directory, "pert_min_loss/", filename), "w") do io
        PMs.export_matpower(io, data_pert_min_loss)
    end
    open(string(output_directory, "pert_min_cost/", filename), "w") do io
        PMs.export_matpower(io, data_pert_min_cost)
    end

    return (result_pert_loss, result_pert_cost)
end

"Set the variable num_cases to determine how many cases to solve"
num_cases = 20

test_directory = "test/data/pglib_tests/"
output_directory = "examples/test_perturbation_outputs/"
try
    mkdir(output_directory)
catch y
    println("Folder already exists, continuing")
end
try
    mkdir(string(output_directory, "pert_min_loss"))
    mkdir(string(output_directory, "pert_min_cost"))
catch y
    println("Folder already exists, continuing")
end
result_dict = Dict()
# Sort the list of cases by size
sorted_directory = sort(
    readdir(test_directory),
    by = f -> parse(Int, strip(split(f, "_")[3][5:end], ['w', 'o', 'p', 's']))
)
for filename in sorted_directory[1: num_cases]
    println("Testing ", filename)
    result_dict[filename] = check_dataset_perturbation(test_directory, output_directory, filename, 0.01, 1, 50)
end
