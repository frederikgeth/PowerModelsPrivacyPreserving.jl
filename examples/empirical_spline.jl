#!/usr/bin/env julia
using Pkg
pkg"activate ."

using JuMP
using Ipopt
using Distributions
using PowerModels
using Plots
using LazySets
using PyCall
interpolate = pyimport("scipy.interpolate")

#include("/Users/feu004/Documents/Julia/PowerModelsPrivacyPreserving.jl/src/PowerModelsPrivacyPreserving.jl")
#using PowerModelsPrivacyPreserving

ipopt = Ipopt.Optimizer
file =  "/Users/feu004/Documents/Julia/PowerModelsPrivacyPreserving.jl/test/data/matpower/case5.m"

num_optimisations = 5000
power_array = Array{Float64}(undef, length(data_unpert["branch"]), num_optimisations, 2)

# Solve the OPF problem, and get the results for each branches
for i in 1:num_optimisations
    data_unpert = parse_file(file)
    for j in 1:length(data_unpert["gen"])
            data_unpert["gen"][string(j)]["pg"] = rand(Uniform(data_unpert["gen"][string(j)]["pmin"], data_unpert["gen"][string(j)]["pmax"]))
            data_unpert["gen"][string(j)]["qg"] = rand(Uniform(data_unpert["gen"][string(j)]["qmin"], data_unpert["gen"][string(j)]["qmax"]))
    end    
    temp_sol = run_ac_pf(data_unpert, Ipopt.Optimizer)
    update_data!(data_unpert, temp_sol["solution"])
    temp_flows = calc_branch_flow_ac(data_unpert)
    update_data!(temp_sol, temp_flows)
    for (key, val) in temp_sol["branch"]
        power_array[parse(Int64, key), i, 1] = val["pf"]
        power_array[parse(Int64, key), i, 2] = val["qf"]
    end
end

# Get the active and reactive power components of the generators
#power_array = Array{Float64,2}(undef, 5, 2)
#for i in 1:length(data_unpert["gen"])
#    power_array[i,1] = data_unpert["gen"][string(i)]["qg"]
#    power_array[i,2] = data_unpert["gen"][string(i)]["qg"]
#end

#num_samples = 1000
# Sample from Laplace distribution
laplace_dist = Laplace()
laplace_perturbs = rand(laplace_dist, 2 * length(data_unpert["branch"]) * num_optimisations)
laplace_perturbs = reshape(laplace_perturbs, (length(data_unpert["branch"]), num_optimisations, 2))

#TODO: need something in here to utilise the alphas up and downstream, to weight the samples


# Perturb the samples using Laplace noise
sample_array = Array{Float64}(undef, length(data_unpert["branch"]), num_optimisations, 2)
sample_array = power_array + laplace_perturbs

# Perturb the power components from bootstrapped samples, uniformly from the generators
#uniform_dist = DiscreteUniform(1,5)
#sample_array = Array{Float64,2}(undef, num_samples, 2)
#for i in 1:num_samples
#    uniform_sample = rand(uniform_dist,2)
#    sample_array[i,1] = tuple_array[uniform_sample[1],1] + laplace_perturbs[i,1]
#    sample_array[i,2] = tuple_array[uniform_sample[1],2] + laplace_perturbs[i,2]
#end

plot(sample_array[1,:,1], sample_array[1,:,2], seriestype= :scatter)

# Sum of the squares of active and reactive power
sum_squares = Array{Float64}(undef, length(data_unpert["branch"]), num_optimisations)
for i in 1:length(data_unpert["branch"])
    sum_squares[i,:] = sample_array[i,:,1].^2 + sample_array[i,:,2].^2
end

# Have to enforce a threshold........revisit
pmax = data_unpert["branch"]["1"]["rate_a"]
prob = 0.95
# This is NOT removing the points i expect......need to solve this problem, then the splones will work out
# Need to do this for all........once i understand the pmax situation
ind = sortperm(sum_squares[1,:])[1:Int(floor(length(sum_squares[1,:][sum_squares[1,:].<=pmax])/prob))]

# Get the coordinates within the chance constraint, have it only for the first branch at the moment, generalise
x_samples = sample_array[1,ind,1]
y_samples = sample_array[1,ind,2]

# Get last few elements of the array, to form the boundary of the constraint
num_boundary = 500
x_boundary = x_samples[length(x_samples)-num_boundary:length(x_samples)]
y_boundary = y_samples[length(y_samples)-num_boundary:length(y_samples)]

# Get the indices ordered by the x-value, needed to use the spline functions
sorted_indices = sortperm(x_boundary)
x_boundary_spline = x_boundary[sorted_indices]
y_boundary_spline = y_boundary[sorted_indices]

# Split the boundary into components of the positive and negative y components, to get interpolate around the boundary
x_boundary_spline_positive = x_boundary_spline[y_boundary_spline .>= 0]
y_boundary_spline_positive = y_boundary_spline[y_boundary_spline .>= 0]
x_boundary_spline_negative = x_boundary_spline[y_boundary_spline .< 0]
y_boundary_spline_negative = y_boundary_spline[y_boundary_spline .< 0]

# Create the two spline interpolations, change to k=2 meaning quadratic
spl_positive = interpolate.splrep(x_boundary_spline_positive, y_boundary_spline_positive, k=1)
spl_negative = interpolate.splrep(x_boundary_spline_negative, y_boundary_spline_negative, k=1)

positive_spline_range = LinRange(minimum(x_boundary_spline_positive), maximum(x_boundary_spline_positive), 100)
negative_spline_range = LinRange(minimum(x_boundary_spline_negative), maximum(x_boundary_spline_negative), 100)

y_spl_positive = interpolate.splev(positive_spline_range, spl_positive)
y_spl_negative = interpolate.splev(negative_spline_range, spl_negative)

L = LineSegment([negative_spline_range[1], y_spl_negative[1]], [positive_spline_range[1], y_spl_positive[1]])

plot(x_boundary_spline, y_boundary_spline, seriestype= :scatter)
plot!(positive_spline_range, y_spl_positive)
plot!(negative_spline_range, y_spl_negative)
plot!(L)