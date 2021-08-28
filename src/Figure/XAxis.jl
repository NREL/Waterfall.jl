mutable struct XAxis <: Axis
    ticks::Ticks
    ticklabels::Vector{Label{Vector{String}}}
    ticksublabels::Vector{Label{Vector{String}}}
    lim::Tuple
end


XAxis( ; ticks, ticklabels, ticksublabels, lim) = XAxis(ticks, ticklabels, ticksublabels, lim)