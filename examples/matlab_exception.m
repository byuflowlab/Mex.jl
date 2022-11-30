% An example of a MATLAB exception caught in Julia and passed back to
% MATLAB (with the Julia backtrace appended)
function matlab_exception()

try
    call_matlab_function(exn_thrower);
catch e
    disp(getReport(e));
end

end

