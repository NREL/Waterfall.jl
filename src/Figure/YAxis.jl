mutable struct YAxis <: Axis
    label::String
    ticks::Ticks
    ticklabels::Array{Union{Label,Missing}}
    lim::Tuple
end


YAxis( ; label, ticks, ticklabels, lim) = YAxis(label, ticks, ticklabels, lim)