%% tests for jl.call function

% check that mexjulia mex file exists
assert(exist("mexjulia", "file") == 3)

% run test
result = jl.call('factorial', int64(10));
assert(isequal(result, factorial(10)))