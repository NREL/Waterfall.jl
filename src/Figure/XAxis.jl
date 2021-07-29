mutable struct XAxis <: Axis
    label::String
    ticklabels::AbstractArray
    ticksublabels::AbstractArray
    ticks::AbstractArray
    lim::Tuple
end


function XAxis( ; label, ticklabels, ticksublabels=[], ticks, lim)
# function Axis( ; label="", ticklabels=[], ticksublabels=[], ticks=[], lim=tuple())
    isempty(ticksublabels) && (ticksublabels = fill("", size(ticklabels)))
    return XAxis(label, ticklabels, ticksublabels, ticks, lim)
end