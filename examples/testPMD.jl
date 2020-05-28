using Ipopt
using PowerModelsDistribution
const PMD = PowerModelsDistribution
# documentation https://lanl-ansi.github.io/PowerModelsDistribution.jl

eng = parse_file("./test/data/opendss/case3_unbalanced.dss")
math = parse_file("./test/data/opendss/case3_unbalanced.dss"; data_model=MATHEMATICAL)

ipopt_solver = Ipopt.Optimizer
result = run_mc_opf(eng, ACPPowerModel, ipopt_solver)

result = run_mc_opf(math, ACPPowerModel, ipopt_solver)
