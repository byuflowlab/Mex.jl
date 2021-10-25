%% tests for jl.call function

result = jl.call('factorial', int64(10));
assert(isequal(result, factorial(10)))