%% tests for jl.call function

result = jl.call('factorial', int64(10));
assert(result == factorial(10))


%% jl.eval

result = jl.eval('2+2');
assert(result == 4)

[s, c] = jl.eval('sin(pi/3), cos(pi/3)');
assert(s = sin(pi/3))
assert(c = cos(pi/3))

jleval 1 + 1
assert(ans == 2)