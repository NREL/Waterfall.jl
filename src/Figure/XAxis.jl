mutable struct XAxis <: Axis
    ticks::Ticks
    ticklabels::Array{Union{Labelbox,Missing}}
    ticksublabels::Array{Union{Labelbox,Missing}}
    lim::Tuple
end


XAxis( ; ticks, ticklabels, ticksublabels, lim) = XAxis(ticks, ticklabels, ticksublabels, lim)