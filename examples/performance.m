function performance()
%% Mex.jl Performance Overhead
% Here we test the performance overhead of the various ways of calling Julia
% We use the divrem function, since it is very quick and shows how to
% handle multiple arguments

%% Simple method
% Just use jl.call
[a,b] = jl.call('divrem',7,3);
% time it:
tic; for i=1:1000; [a,b] = jl.call('divrem',7,3); end; elpsd = toc;
fprintf('jl.call: %3.0f us/call\n',elpsd*1e3);

%% Custom Julia method
% Here we make a 'MEX-like julia function
jleval divrem_mat(args::Vector{MATLAB.MxArray}) = divrem(MATLAB.jscalar(args[1]),MATLAB.jscalar(args[2]));
% and we use jl.mex
[a,b] = jl.mex('divrem_mat',7,3);
% time it:
tic; for i=1:1000; [a,b] = jl.mex('divrem_mat',7,3); end; elpsd = toc;
fprintf('jl.mex:  %3.0f us/call\n',elpsd*1e3);

%% Custom mexjulia wrapper
% We make a special wrapper (see below) to call mexjulia directly. This
% method also requires the MEX-like Julia function we made earlier.
[a,b] = divrem(7,3);
% time it:
tic; for i=1:1000; [a,b] = divrem(7,3); end; elpsd = toc;
fprintf('direct:  %3.0f us/call\n',elpsd*1e3);
end

function [o1,o2] = divrem(a,b)
[rv,o1,o2] = mexjulia('jl_mex', 'divrem_mat', a, b);
if ~islogical(rv); throw(rv); end
end
