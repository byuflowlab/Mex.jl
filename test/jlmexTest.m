%% tests for jl.mex function

a = rand(5,5);
jleval import MATLAB;
jleval double_it(args::Vector{MATLAB.MxArray}) = [2*MATLAB.jvalue(arg) for arg in args];
result = jl.mex('double_it', a);
result = result{1};
expected_result = 2*a;
assert (isequal(result, expected_result))