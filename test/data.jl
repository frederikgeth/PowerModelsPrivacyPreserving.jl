@testset "test function create_impedance_perturbation" begin
    file =  "../test/data/matpower/case5.m"
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
