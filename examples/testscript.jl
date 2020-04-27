using Ipopt
using Main.PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random

const PMs = PowerModels
const PMPP = Main.PowerModelsPrivacyPreserving


ipopt = Ipopt.Optimizer
file =  "test/data/matpower/case5.m"
data_unpert = parse_file(file)
data_min_loss = deepcopy(data_unpert)
data_min_cost = deepcopy(data_unpert)


"this is the canonical OPF problem with generation cost minimization"
result_unpert_cost = PMPP.run_ac_opf_cost(data_unpert, ipopt)
PMs.print_summary(result_unpert_cost["solution"])
PMPP.calculate_losses!(result_unpert_cost, data_unpert)
"store faithfulness info"
data_min_cost["cost"] = Dict()
data_min_cost["cost"]["value"] = result_unpert_cost["objective"]
data_min_cost["cost"]["beta"] = 1

"this variant of the OPF problem minimizes grid losses instead of generation cost"
result_unpert_loss = PMPP.run_ac_opf_loss(data_unpert, ipopt)
PMs.print_summary(result_unpert_loss["solution"])
PMPP.calculate_losses!(result_unpert_loss, data_unpert)
"store faithfulness info"
data_min_loss["loss"] = Dict()
data_min_loss["loss"]["value"] = result_unpert_loss["totalloss"]
data_min_loss["loss"]["beta"] = 1

# Set constant parameters
α = 0.01
ϵ = 1
λ = 50

# Add impedance perturbation to both data dictionaries.
data_pert_min_loss = PMPP.create_impedance_perturbation(data_min_loss, α, ϵ, λ)
data_pert_min_cost = PMPP.create_impedance_perturbation(data_min_cost, α, ϵ, λ)

# Calculate the result
result_pert_loss = PMPP.run_opf_variable_impedance_loss(data_pert_min_loss, ipopt)
PMs.print_summary(result_pert_loss["solution"])
PMPP.calculate_losses!(result_pert_loss, data_pert_min_loss)

result_pert_cost = PMPP.run_opf_variable_impedance_cost(data_pert_min_cost, ipopt)
PMs.print_summary(result_pert_cost["solution"])
PMPP.calculate_losses!(result_pert_cost, data_pert_min_cost)
