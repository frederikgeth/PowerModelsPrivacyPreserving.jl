using Ipopt
using Main.PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random

const PMs = PowerModels
const PMPP = Main.PowerModelsPrivacyPreserving


###############################################################################
"Start working here"

ipopt = Ipopt.Optimizer
file =  "test/data/matpower/case5.m"
data_unpert = parse_file(file)
data_pert = deepcopy(data_unpert)

result_unpert = PMPP.run_ac_opf_test(data_unpert, ipopt)

# Apply laplace noise to the g values for each branch (eq 15)
alpha = 0.01
eps = 1 #
lap = Laplace(0, 3 * alpha / eps)
global sum_g = 0
global sum_b = 0
for (l, branch) in data_pert["branch"]
    global sum_g
    global sum_b
    noise = Random.rand(lap, 1)[1]
    z = branch["br_r"] + im*branch["br_x"]
    y = 1/z
    g = real(y)
    b = imag(y)
    println("g is: ", g)
    println("b is: ", b)
    r = g/b # Check that this is correct as it was a typo in paper?
    pert_b = b + noise
    pert_g = r * pert_b
    branch["g_obj"] = pert_g
    branch["b_obj"] = pert_b
    println("perturbed g is: ", pert_g)
    println("perturbed b is: ", pert_b)
    sum_g += g
    sum_b += b
end

# Calculate the noisy mean (eq 16, eq 17)
n = size(collect(data_pert["branch"]), 1)
lap_mu = Laplace(0, 3 * alpha / (n * eps))
mu_g = (1 / n) * sum_g + Random.rand(lap_mu, 1)[1]
mu_b = (1 / n) * sum_b + Random.rand(lap_mu, 1)[1]

# What should lambda value be? not clear in paper
# I think this might be here to stop the system from spitting out negative
# values. This has been a problem in another project I worked on.
lambda = 50

# Add noisy mean limit values to our data dictionary
data_pert["g_lb"] = mu_g / lambda
data_pert["g_ub"] = mu_g * lambda
# b is negative so need to swap the upper and lower bounds?

# TODO: This must be wrong
bb1 =mu_b * lambda
bb2 =mu_b / lambda
data_pert["b_lb"] = min(bb1,bb2)
data_pert["b_ub"] = max(bb1,bb2)

# Set beta to a value from the paper
data_pert["beta"] = 0.01

# Set the O* value to be the result of the original model output
data_pert["O_star"] = result_unpert["objective"]

result_pert = PMPP.run_ac_opf_variable_impedance(data_pert, ipopt)

PMPP.calculate_losses!(result_unpert, data_unpert)
PMPP.calculate_losses!(result_pert, data_pert)
