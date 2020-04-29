import PowerModelsPrivacyPreserving
const PMPP = PowerModelsPrivacyPreserving

import Memento

import InfrastructureModels

import PowerModels
const PMs = PowerModels

# Suppress warnings during testing.
const TESTLOG = Memento.getlogger(PowerModels)
Memento.setlevel!(TESTLOG, "error")

import JuMP
import Ipopt

using Test
using LinearAlgebra



# default setup for solvers
ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0)

@testset "PowerModelsPrivacyPreserving" begin
    include("opf.jl")

    include("opf_impedance.jl")

    include("data.jl")

end
