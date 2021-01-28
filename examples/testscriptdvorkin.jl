using Ipopt
using PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random
using ECOS
using JSON
using JuMP

const PM = PowerModels
const PMPP = PowerModelsPrivacyPreserving

ipopt = Ipopt.Optimizer
file =  "test/data/matpower/test_3_bus.m"
# test_directory = "test/data/matpower/"
# # for file in readdir(test_directory)
# println(file)
# println()
# # data = PM.parse_file(string(test_directory, file))
data = PM.parse_file(file)
# print(data)
# quit()
# data = JSON.parsefile("test/data/output.json")
# println(data)

# Work out upstream and downstream nodes
create_network_diagram!(data)
# println(data)

# # Set chance constraint parameters
η_g = 0.1; η_u = 0.1; η_f = 0.1
set_chance_constraint_etas!(data, η_g, η_u, η_f)

# # Set privacy parameters Ref: DP_CC_OPF.jl line 40
δ = 1 / (length(data["bus"]) - 1)
ϵ = 1000
set_privacy_parameters!(data, δ, ϵ)

# # Set the power factor for the problem.
# # Currently, this is constant across the entire network diagram
set_power_factor!(data, 0.5)

# # Set the inner polygon coefficients
# # TODO: Generate these based on specified cardinality
set_inner_polygon_coefficients!(data)

# PMPP.run_ac_opf_cost(data, ipopt)
# result_unpert_cost = PMPP.run_opf_bf_dvorkin(data, BFAPowerModel, ipopt)

# Create model pm so that we can accesss it after, then solve the proplem
optimizer = JuMP.optimizer_with_attributes(ECOS.Optimizer, "maxit" => 500)
pm = instantiate_model(data, BFAPowerModel, PMPP.build_opf_bf_dvorkin_cc)
result_unpert_cost_cc = optimize_model!(pm, optimizer=optimizer)

# Create laplace distribution
laplace_distribution_arr = [Distributions.Laplace(0, branch_dict["σ"]) for (k, branch_dict) in data["branch"]]
xi_dim_l = vec([Random.rand(laplace_distribution) for laplace_distribution in laplace_distribution_arr])

# Get values from model
# 2b)
α = JuMP.value.(PowerModels.var(pm, :α)).data
# 3a)
pg = JuMP.value.(PowerModels.var(pm, :pg)).data
qg = JuMP.value.(PowerModels.var(pm, :qg)).data
# 3b)
p = JuMP.value.(PowerModels.var(pm, :p)).data
q = JuMP.value.(PowerModels.var(pm, :q)).data
# 3c)
u = JuMP.value.(PowerModels.var(pm, :w)).data

# Apply perturbations to each value
function get_signed_alpha(α, n, l, branch_dict)
    if n in branch_dict["upstream_nodes"]
        return α[n, l]
    elseif n in branch_dict["downstream_nodes"]
        return -α[n, l]
    else
        return 0
    end
end

# 3a)
pg_tilde = pg + [vec([get_signed_alpha(α, n, parse(Int, branch_index), branch_dict) 
                    for (branch_index, branch_dict) in data["branch"]])' * xi_dim_l 
                        for n in 1:length(pg)]
qg_tilde = qg + [vec([get_signed_alpha(α, n, parse(Int, branch_index), branch_dict)
                    for (branch_index, branch_dict) in data["branch"]])' * xi_dim_l 
                        for n in 1:length(qg)]

# 3b) TODO: We are not using the p and q value from branches in reverse, should we?
fp_tilde = p[1:2] - [sum([vec([get_signed_alpha(α, j, parse(Int, branch_index), branch_dict) 
                                for (branch_index, branch_dict) in data["branch"]]) 
                                    for j in data["branch"][string(l)]["downstream_nodes"]])' * xi_dim_l 
                                        for l in 1:length(p[1:2])]
fq_tilde = q[1:2] - [sum([vec([get_signed_alpha(α, j, parse(Int, branch_index), branch_dict) 
                                for (branch_index, branch_dict) in data["branch"]]) 
                                    for j in data["branch"][string(l)]["downstream_nodes"]])' * xi_dim_l 
                                        for l in 1:length(q[1:2])]

# 3c) Alebraic simplification used to make statement more tractable
# Use u[2:end] to avoid perturbing the root node
u_tilde = u[2:end] + 2 * 
    [sum(
        [sum(
            [vec(
                [(data["branch"][string(j)]["br_r"] + data["branch"][string(j)]["br_x"] * data["tanϕ"]) * 
                get_signed_alpha(α, k, parse(Int, branch_index), branch_dict) 
                for (branch_index, branch_dict) in data["branch"]]) 
            for k in data["branch"][string(j)]["downstream_nodes"]])
        for j in data["branch"][string(l)]["upstream_branches"]])' * xi_dim_l 
    for l in 1:length(u) - 1]
