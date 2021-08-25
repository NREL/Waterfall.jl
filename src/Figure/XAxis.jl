mutable struct XAxis <: Axis
    ticks::Ticks
    ticklabels::Array{Union{Label,Missing}}
    ticksublabels::Array{Union{Label,Missing}}
    lim::Tuple
end


XAxis( ; ticks, ticklabels, ticksublabels, lim) = XAxis(ticks, ticklabels, ticksublabels, lim)