% tests for jl.mex function

% check that mexjulia mex file exists
assert(exist("mexjulia", "file") == 3)

%% Test 1: jl.mex
a = rand(5,5);
jleval double_it(args::Vector{Mex.MxArray}) = [2*Mex.jvalue(arg) for arg in args];
result = jl.mex('double_it', a);
result = result{1};
expected_result = 2*a;
assert(isequal(result, expected_result))