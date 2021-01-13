@testset "test function create_impedance_perturbation" begin
    file =  "test/data/matpower/case5.m"
    # Set up dummy scenario
    data = PMs.parse_file(file)
    α = 0.01
    ϵ = 1
    λ = 50
    # Apply the perturbation to this scenario
    perturbed_data = PMPP.create_impedance_perturbation(data, α, ϵ, λ)
    # Check that the new parameters have been returned
    @test haskey(perturbed_data, "g_lb")
    @test haskey(perturbed_data, "g_ub")
    @test haskey(perturbed_data, "b_lb")
    @test haskey(perturbed_data, "b_ub")
    # Check that all other required parameters have been returned
    for (key, value) in data
        @test haskey(perturbed_data, key)
    end

end

# @testset "test function create_network_diagram" begin
#     file =  "test/data/matpower/test_3_bus.m"
#     data = PMs.parse_file(file)
#     PMPP.create_network_diagram!(data)
# end

@testset "test function set_chance_constraint_etas" begin
    file =  "test/data/matpower/test_3_bus.m"
    data = PMs.parse_file(file)
    η_g = 0.1; η_u = 0.1; η_f = 0.1
    PMPP.set_chance_constraint_etas!(data, η_g, η_u, η_f)
    @test haskey(data, "η_g")
    @test haskey(data, "η_u")
    @test haskey(data, "η_f")
end

@testset "test function set_privacy_parameters" begin
    # Test that the function sets the dictionary parameters
    file =  "test/data/matpower/test_3_bus.m"
    data = PMs.parse_file(file)
    PMPP.create_network_diagram!(data)
    δ = 1 / (length(data["bus"]) - 1)
    ϵ = 1000
    PMPP.set_privacy_parameters!(data, δ, ϵ)
    for (i, branch) in data["branch"]
        @test haskey(branch, "σ")
    end

end

@testset "test function set_power_factor" begin
    # Test that the function correctly sets the dictionary parameters
    file =  "test/data/matpower/test_3_bus.m"
    data = PMs.parse_file(file)
    PMPP.set_power_factor!(data, 0.5)
    @test data["tanϕ"] == 0.5
end

@testset "test function set_inner_polygon_coefficients" begin
    # Test that the function sets the dictionary parameters
    file =  "test/data/matpower/test_3_bus.m"
    data = PMs.parse_file(file)
    PMPP.set_inner_polygon_coefficients!(data)
    @test haskey(data, "C")
    @test haskey(data, "α_f")
    @test haskey(data, "β_f")
    @test haskey(data, "δ_f")
end
