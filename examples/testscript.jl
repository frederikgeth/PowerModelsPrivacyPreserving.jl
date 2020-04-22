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
data_pert_loss = deepcopy(data_unpert)
data_pert_cost = deepcopy(data_unpert)



"this is the canonical OPF problem with generation cost minimization"
result_unpert_cost = PMPP.run_ac_opf_cost(data_unpert, ipopt)
PMs.print_summary(result_unpert_cost["solution"])
PMPP.calculate_losses!(result_unpert_cost, data_unpert)
"store faithfulness info"
data_pert_cost["cost"] = Dict()
data_pert_cost["cost"]["value"] = result_unpert_cost["objective"]
data_pert_cost["cost"]["beta"] = 1

"this variant minimizes grid losses instead"
result_unpert_loss = PMPP.run_ac_opf_loss(data_unpert, ipopt) #this one minimizes grid losses instead
PMs.print_summary(result_unpert_loss["solution"])
PMPP.calculate_losses!(result_unpert_loss, data_unpert)
"store faithfulness info"
data_pert_loss["loss"] = Dict()
data_pert_loss["loss"]["value"] = result_unpert_loss["totalloss"]
data_pert_loss["loss"]["beta"] = 1

# Apply laplace noise to the g values for each branch (eq 15)
α = 0.01
ϵ = 1 #
lap = Laplace(0, 3 * α / ϵ)

function add_impedance_perturbation!(data, distribution)
    sum_g = 0
    sum_b = 0
    for (l, branch) in data["branch"]
        noise = Random.rand(distribution, 1)[1]
        z = branch["br_r"] + im*branch["br_x"]
        y = 1/z
        g = real(y)
        b = imag(y)
        println("g is: ", g)
        println("b is: ", b)
        
        # the following codes have been changed by Ming Ding on Apr. 8th, 2020
        # it would be better to follow the definition of r in Algorithm 1 and eq. (15)
        # r = g/b # Check that this is correct as it was a typo in paper?
        # pert_b = b + noise # noisy susceptances
        # pert_g = r * pert_b # get noisy conductances

        r = b/g # Algorithm 1 and eq. (15)
        pert_g = g + noise # noisy conductances
        pert_b = r * pert_g # get noisy susceptances

        branch["g_obj"] = pert_g
        branch["b_obj"] = pert_b
        println("perturbed g is: ", pert_g)
        println("perturbed b is: ", pert_b)
        sum_g += g
        sum_b += b
    end

    return sum_g, sum_b
end
g_loss, b_loss = add_impedance_perturbation!(data_pert_loss, lap)
g_cost, b_cost = add_impedance_perturbation!(data_pert_cost, lap)

# Calculate the noisy mean (eq 16, eq 17)
n = length(data_pert_loss["branch"])
lap_μ = Laplace(0, 3 * α / (n * ϵ))
function mu_impedance(distribution, sum_g, sum_b, n_branches)
    μ_g = (1 / n_branches) * sum_g + Random.rand(distribution, 1)[1]
    μ_b = (1 / n_branches) * sum_b + Random.rand(distribution, 1)[1]
    return μ_g, μ_b
end
μ_g_loss, μ_b_loss = mu_impedance(lap_μ, g_loss, b_loss, n)
μ_g_cost, μ_b_cost = mu_impedance(lap_μ, g_cost, b_cost, n)

# What should lambda value be? not clear in paper
# I think this might be here to stop the system from spitting out negative
# values. This has been a problem in another project I worked on.
# Ming: My original understanding is that lambda = 3*alpha/eps. See the last paragraph, left column, page 4.
# lambda = 50
λ = 50

# Add noisy mean limit values to our data dictionary
data_pert_cost["g_lb"] = μ_g_cost / λ
data_pert_cost["g_ub"] = μ_g_cost * λ

data_pert_loss["g_lb"] = μ_g_loss / λ
data_pert_loss["g_ub"] = μ_g_loss * λ
# b is negative so need to swap the upper and lower bounds?

# TODO: This must be wrong
bb1_loss = μ_b_loss * λ
bb2_loss = μ_b_loss / λ
data_pert_loss["b_lb"] = min(bb1_loss,bb2_loss)
data_pert_loss["b_ub"] = max(bb1_loss,bb2_loss)

bb1_cost = μ_b_cost * λ
bb2_cost = μ_b_cost / λ
data_pert_cost["b_lb"] = min(bb1_cost,bb2_cost)
data_pert_cost["b_ub"] = max(bb1_cost,bb2_cost)


result_pert_loss = PMPP.run_opf_variable_impedance_loss(data_pert_loss, ipopt)
PMs.print_summary(result_pert_loss["solution"])
PMPP.calculate_losses!(result_pert_loss, data_pert_loss)

result_pert_cost = PMPP.run_opf_variable_impedance_cost(data_pert_cost, ipopt)
PMs.print_summary(result_pert_cost["solution"])
PMPP.calculate_losses!(result_pert_cost, data_pert_cost)
