# --- Calling Embedded Julia from MATLAB --- #

# entry point for MATLAB calling Julia
jl_mex(plhs::Vector{Ptr{Cvoid}}, prhs::Vector{Ptr{Cvoid}}) = jl_mex_inner(plhs, prhs)

# runs julia function with mex function inputs, catching errors if they occur
function jl_mex_inner(plhs::Vector{Ptr{Cvoid}}, prhs::Vector{Ptr{Cvoid}})

    # get number of outputs
    nlhs = length(plhs)

    for i = 1:nlhs
        # default output is boolean false
        none = MATLAB.mxarray(false);
        # transfer ownership to MATLAB
        none.own = false
        # give pointer to MATLAB
        plhs[i] = none.ptr
    end

    try

        # extract function and arguments (function in first slot, arguments in remaining slots)
        fun = Core.eval(Main, Meta.parse(MATLAB.jvalue(MATLAB.MxArray(prhs[1], false))))
        args = MATLAB.MxArray.(prhs[2:end], false)

        # call Julia function
        vals = fun(args)

        # convert outputs to MxArray type
        for i = 1:length(vals)
            # stop early if max number of outputs is reached
            if i > nlhs-1
                break
            end
            # create MATLAB array for output
            mx = MATLAB.mxarray(vals[i])
            # transfer ownership to MATLAB
            mx.own = false
            # give pointer to MATLAB
            plhs[1+i] = mx.ptr
        end

    catch exn

        # get backtrace
        bt = catch_backtrace()

        # create MATLABException from exception and backtrace
        mexn = MatlabException(exn, bt)

        # return MATLABexception in first output slot
        plhs[1] = mexn.ptr

    end

end

# --- Functions Used by MATLAB when calling embedded Julia --- #

# evaluates a Julia expressions
jl_eval(exprs::Vector{MATLAB.MxArray}) = [Core.eval(Main, Meta.parse(MATLAB.jvalue(e))) for e in exprs]

# Call a julia function, possibly with keyword arguments.
#
# The values in the args array are interpreted as follows:
#      Index = Meaning
# -----------------------------------------------------------
#          1 = the function to call
#          2 = an integer, npos, the number of positional arguments
#   3:2+npos = positional arguments
# 3+npos:end = keyword arguments, in keyword/value pairs
#
# If npos < 0, all arguments are assumed positional.
function jl_call_kw(args::Vector{MATLAB.MxArray})

    # convert arguments to Julia objects
    vals = MATLAB.jvalue.(args)
    nvals = length(args)

    # first argument is the function
    func = Symbol(vals[1])

    # second argument is the number of positional arguments
    npos = vals[2]

    # if npos is negative, all arguments are positional
    if npos < 0
        npos = nvals - 2
    end

    # get number of keyword arguments
    nkw = div(nvals - 2 - npos, 2)

    # initialize arguments to julia expression
    expr_args = Array{Any, 1}(undef, npos+nkw)

    # add positional arguments
    for i = 1:npos
        expr_args[i] = vals[2+i]
    end

    # add keyword arguments
    for i = 1:nkw
        # assemble the key-value pair
        kw = Symbol(vals[2+npos+(2*i-1)])
        val = vals[2+npos+(2*i)]
        expr_args[npos+i] = Expr(:kw, kw, val)
    end

    # construct the expression
    expr = Expr(:call, func, expr_args...)

    # return the evaluated expression
    return [Core.eval(Main, expr)]
end

# used for mimicing a basic Julia repl from the MATLAB console
input(prompt::String="julia> ") = call_matlab(1, "input", prompt, "s")[1]
