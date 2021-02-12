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
file =  "test/data/matpower/nesta_case57_kds__rad.m"

# Solves for the following:
# test/data/matpower/nesta_case57_kds__rad.m η_g = 0.01; η_u = 0.01; η_f = 0.01 ϵ = 1000
# test/data/matpower/nesta_case57_l_kds__rad.m η_g = 0.01; η_u = 0.01; η_f = 0.01 ϵ = 1000

# test_directory = "test/data/matpower/"
data = PM.parse_file(file)

# Work out upstream and downstream nodes
create_network_diagram!(data)

# # Set chance constraint parameters
η_g = 0.05; η_u = 0.05; η_f = 0.05
set_chance_constraint_etas!(data, η_g, η_u, η_f)

# # Set privacy parameters Ref: DP_CC_OPF.jl line 40
δ = 1 / (length(data["bus"]) - 1)
ϵ = 10
set_privacy_parameters!(data, δ, ϵ)

# # Set the power factor for the problem.
# # Currently, this is constant across the entire network diagram
set_power_factor!(data, 0.5)

# # Set the inner polygon coefficients
set_inner_polygon_coefficients!(data)

# Create model pm so that we can accesss it after, then solve the proplem
optimizer = JuMP.optimizer_with_attributes(ECOS.Optimizer, "maxit" => 500)
pm = instantiate_model(data, BFAPowerModel, PMPP.build_opf_bf_dvorkin_cc)
result_unpert_cost_cc = optimize_model!(pm, optimizer=optimizer)

# Instantiate ξ values for each branch
for (branch_index, branch_dict) in data["branch"]
    if branch_dict["σ"] == 0
        branch_dict["ξ"] = 0
    else
        branch_dict["ξ"] = Random.rand(Distributions.Laplace(0, branch_dict["σ"]))
    end
end

# Get values from model
# 2b)
α = JuMP.value.(PowerModels.var(pm, :α)).data
# 3a)
pg = JuMP.value.(PowerModels.var(pm, :pg)).data
qg = JuMP.value.(PowerModels.var(pm, :qg)).data
# 3b) Only perturb the forward directional arcs
arcs_from_keys = PowerModels.ref(pm, :arcs_from)
p_dict = JuMP.value.(PowerModels.var(pm, :p))
p = [p_dict[arc_key] for arc_key in arcs_from_keys]
q_dict = JuMP.value.(PowerModels.var(pm, :q))
q = [q_dict[arc_key] for arc_key in arcs_from_keys]
# 3c)
u = JuMP.value.(PowerModels.var(pm, :w)).data

# Calculate perturbed values according to equation set 3)
# 3a)
pg_tilde = pg + [sum([PMPP.get_signed_alpha(pm, α, n, parse(Int, branch_index)) * branch_dict["ξ"]
                    for (branch_index, branch_dict) in data["branch"]])  
                        for n in 1:length(pg)]
qg_tilde = qg + [sum([PMPP.get_signed_alpha(pm, α, n, parse(Int, branch_index)) * branch_dict["ξ"]
                    for (branch_index, branch_dict) in data["branch"]]) 
                        for n in 1:length(qg)]

# 3b)
fp_tilde = p - [sum([sum([PMPP.get_signed_alpha(pm, α, j, parse(Int, branch_index)) * branch_dict["ξ"]
                                for (branch_index, branch_dict) in data["branch"]]) 
                                    for j in data["branch"][string(l)]["downstream_nodes"]]) 
                                        for l in 1:length(p)]
fq_tilde = q - [sum([sum([PMPP.get_signed_alpha(pm, α, j, parse(Int, branch_index)) * branch_dict["ξ"]
                                for (branch_index, branch_dict) in data["branch"]]) 
                                    for j in data["branch"][string(l)]["downstream_nodes"]])
                                        for l in 1:length(q)]

# 3c) Alebraic simplification used to make statement more tractable
# Use u[2:end] to avoid perturbing the root node
u_tilde = u[2:end] + 2 * 
    [sum(
        [sum(
            [sum(
                [(data["branch"][string(j)]["br_r"] + data["branch"][string(j)]["br_x"] * data["tanϕ"]) * 
                PMPP.get_signed_alpha(pm, α, k, parse(Int, branch_index)) * branch_dict["ξ"] 
                for (branch_index, branch_dict) in data["branch"]]) 
            for k in data["branch"][string(j)]["downstream_nodes"]])
        for j in data["branch"][string(l)]["upstream_branches"]])
    for l in 1:length(u) - 1]
