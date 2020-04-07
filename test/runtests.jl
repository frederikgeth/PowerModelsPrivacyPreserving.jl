using PowerModelsPrivacyPreserving
import Memento

# Suppress warnings during testing.
Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
PowerModels.logger_config!("error")

import Ipopt

import JuMP

using Test

# default setup for solvers
ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0)
ipopt_ws_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, mu_init=1e-4, print_level=0)

@testset "PowerModelsPrivacyPreserving" begin

    include("opf.jl")

end
