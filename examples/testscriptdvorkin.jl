using Ipopt
using PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random
using ECOS
using JSON

const PM = PowerModels
const PMPP = PowerModelsPrivacyPreserving

ipopt = Ipopt.Optimizer
# file =  "test/data/matpower/nesta_case57_l_kds__rad.m"
# test_directory = "test/data/matpower/"
# # for file in readdir(test_directory)
# println(file)
# println()
# # data = PM.parse_file(string(test_directory, file))
# correct_data = PM.parse_file(file)
# print(data)
# quit()
data = JSON.parsefile("test/data/output.json")
# println(data)

# Work out upstream and downstream nodes
create_network_diagram!(data)
# println(data)

# # Set chance constraint parameters
η_g = 0.1; η_u = 0.1; η_f = 0.1
set_chance_constraint_etas!(data, η_g, η_u, η_f)

# # Set privacy parameters Ref: DP_CC_OPF.jl line 40
δ = 1 / (length(data["bus"]) - 1)
ϵ = 4
set_privacy_parameters!(data, δ, ϵ)

# # Set the power factor for the problem.
# # Currently, this is constant across the entire network diagram
set_power_factor!(data, 0.5)

# # Set the inner polygon coefficients
# # TODO: Generate these based on specified cardinality
set_inner_polygon_coefficients!(data)

# PMPP.run_ac_opf_cost(data, ipopt)
result_unpert_cost = PMPP.run_opf_bf_dvorkin(data, BFAPowerModel, ipopt)

##
# https://github.com/mlubin/RobustCCOPFSupplement/
# https://github.com/mlubin/RobustCCOPFSupplement/blob/master/codejl/ccopfmodel_simulation.jl
# Lubin, M., Dvorkin, Y., & Backhaus, S. (2015). A robust approach to chance constrained optimal power flow with renewable generation. IEEE Trans. Power Syst., 11. Cryptography and Security. Retrieved from http://arxiv.org/abs/1504.0601
# https://jumpchance.readthedocs.io/en/latest/
# https://github.com/mlubin/JuMPChance.jl
result_unpert_cost_cc = PMPP.run_opf_bf_dvorkin_cc(data, BFAPowerModel, ECOS.Optimizer)
# end