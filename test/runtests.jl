using MATLAB, Test

is_ci() = lowercase(get(ENV, "CI", "false")) == "true"

if !is_ci() # only test if not CI

    @testset "jl.eval" begin

        mat"""
            $result = jl.eval('2+2');
        """
        @test result == 4
    
        mat"""
            [$s, $c] = jl.eval('sin(pi/3), cos(pi/3)');
        """
        @test s ≈ sin(pi/3)
        @test c ≈ cos(pi/3)
    
        mat"""
            jleval 1 + 1;
            $result = ans;
        """
        @test result == 2
    end
    
    @testset "jl.call" begin
        mat"""
            $result = jl.call('factorial', int64(10));
        """
        @test result == factorial(10)
    end
    
    @testset "jl.mex" begin
        mat"""
        a = rand(5,5);
        jleval import MATLAB;
        jleval double_it(args::Vector{MATLAB.MxArray}) = [2*MATLAB.jvalue(arg) for arg in args];
        result = jl.mex('double_it', a);
        $result = result{1};
        $expected_result = 2*a;
        """
        @test result ≈ expected_result
    end
    
end
