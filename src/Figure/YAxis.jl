mutable struct YAxis <: Axis
    label::Label{String}
    ticks::Ticks
    ticklabels::Vector{Label{String}}
    lim::Tuple
end


YAxis( ; label, ticks, ticklabels, lim) = YAxis(label, ticks, ticklabels, lim)