mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    axes::Vector
    # xaxis::Axis
    # yaxis::Axis
    # legend::Vector{Legend}
    # annotation::Vector{Annotation}
end

Plot( ; cascade, xaxis, yaxis) = Plot(cascade, [xaxis, yaxis])