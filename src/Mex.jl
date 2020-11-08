module Mex

using MATLAB, Libdl

export jl_mex, input, call_matlab, is_interrupt_pending, check_for_interrupt

# --- Initialization --- #

# MATLAB mex interface
const libmex = Ref{Ptr{Cvoid}}()
const mex_call_matlab_with_trap = Ref{Ptr{Cvoid}}()

# MATLAB interrupt handling (from undocumented MATLAB)
const libut = Ref{Ptr{Cvoid}}()
const ut_is_interrupt_pending = Ref{Ptr{Cvoid}}()

function __init__()
    libmex[] = Libdl.dlopen(joinpath(MATLAB.matlab_libpath(), "libmex"), Libdl.RTLD_GLOBAL)
    mex_call_matlab_with_trap[] = Libdl.dlsym(libmex[], :mexCallMATLABWithTrap)

    libut[]  = Libdl.dlopen(joinpath(MATLAB.matlab_libpath(), "libut"), Libdl.RTLD_GLOBAL)
    ut_is_interrupt_pending[] = Libdl.dlsym(libut[], :utIsInterruptPending)
end

include("exceptions.jl")
include("juliatomatlab.jl")
include("matlabtojulia.jl")

# Patch MATLAB.jl's handling of tuples
function MATLAB.mxarray(t::Tuple)
    pm = mxcellarray(length(t))
    for i = 1:length(t)
        set_cell(pm, i, mxarray(t[i]))
    end
    return pm
end

# Patch MATLAB.jl's handling of reinterpreted arrays
function MATLAB.mxarray(a::Base.ReinterpretArray{T}) where T<:MATLAB.MxRealNum
    mx = mxarray(T, size(a))
    ccall(:memcpy, Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, UInt), data_ptr(mx), parent(a), length(a)*sizeof(T))
    return mx
end

end # module
