#TODO add unit tests

@testset "test opf minimum losses" begin
    file =  "../test/data/matpower/case5.m"
    data = PMs.parse_file(file)
    result = PMPP.run_ac_opf_cost(data, ipopt_solver)
    @test result["termination_status"] == PMs.LOCALLY_SOLVED
    @test isapprox(result["objective"], 18269.1; atol = 1e-1)
end
