mutable struct YAxis <: Axis
    label::Label{String}
    ticks::Vector{Line}
    ticklabels::Vector{Label{String}}
    frame::Arrow
end


YAxis( ; label, ticks, ticklabels, frame) = YAxis(label, ticks, ticklabels, frame)