#TODO add unit tests

@testset "test opf with variable impedance" begin
    file =  "../test/data/matpower/case5.m"
    data = PMs.parse_file(file)
    # result = PMPP.run_opf_variable_impedance_loss(data, ipopt_solver)
    # @test result["termination_status"] == PMs.LOCALLY_SOLVED
    # @test isapprox(result["objective"], 0; atol = 1e0)
end
