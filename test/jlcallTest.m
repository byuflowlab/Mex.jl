% tests for jl.call function

% check that mexjulia mex file exists
assert(exist("mexjulia", "file") == 3)

%% Test 1: jl.call 
result = jl.call('factorial', int64(10));
assert(isequal(result, factorial(10)))