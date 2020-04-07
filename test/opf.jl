#TODO add unit tests

@testset "test opf minimum losses" begin
    file =  "test/data/matpower/case5.m"
    data = parse_file(file)
    result = PMPP.run_ac_opf_test(data, ipopt_solver)
    @test result["termination_status"] == LOCALLY_SOLVED
    @test isapprox(result["objective"], 5638.97; atol = 1e0)
end
