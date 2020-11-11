abstract type AbstractBFAConicModel <: _PM.AbstractBFAModel end

mutable struct BFAConicPowerModel <: AbstractBFAConicModel _PM.@pm_fields end