% tests for jl.eval function

% check that mexjulia mex file exists
assert(exist("mexjulia", "file") == 3)

%% Test 1: Single Return Argument
try
    result = jl.eval('2+2');
catch err
    disp(getReport(err,'extended'));
end
assert(result == 4)

%% Test 2: Multiple Return Arguments
[s, c] = jl.eval('sin(pi/3), cos(pi/3)');
assert(s == sin(pi/3))
assert(c == cos(pi/3))

%% Test 3: Command Syntax
jleval 1 + 1;
assert(isequal(ans, 2))