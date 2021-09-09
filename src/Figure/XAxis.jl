mutable struct XAxis <: Axis
    ticklabels::Vector{Label{Vector{String}}}
    ticksublabels::Vector{Label{Vector{String}}}
    frame::Line
end

XAxis( ; ticklabels, ticksublabels, frame) = XAxis(ticklabels, ticksublabels, frame)