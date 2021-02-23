using Ipopt
using PowerModelsPrivacyPreserving
using PowerModels
using Distributions
using Random

const PM = PowerModels
const PMPP = PowerModelsPrivacyPreserving


ipopt = Ipopt.Optimizer
file =  "test/data/matpower/case5.m"
data_unpert = PM.parse_file(file)

for (i,gen) in data_unpert["gen"]
    gen["eta"] = 0.95
end
# data_min_loss = deepcopy(data_unpert)
# data_min_cost = deepcopy(data_unpert)


result_unpert_cost = PMPP.run_opf_bf_dvorkin(data_unpert, BFAPowerModel, ipopt)

##
# https://github.com/mlubin/RobustCCOPFSupplement/
# https://github.com/mlubin/RobustCCOPFSupplement/blob/master/codejl/ccopfmodel_simulation.jl
# Lubin, M., Dvorkin, Y., & Backhaus, S. (2015). A robust approach to chance constrained optimal power flow with renewable generation. IEEE Trans. Power Syst., 11. Cryptography and Security. Retrieved from http://arxiv.org/abs/1504.0601
# https://jumpchance.readthedocs.io/en/latest/
# https://github.com/mlubin/JuMPChance.jl
result_unpert_cost_cc = PMPP.run_opf_bf_dvorkin_cc(data_unpert, BFAPowerModel, ipopt)

