mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    axes::Vector
    title::Labelbox
    path::String
    # xaxis::Axis
    # yaxis::Axis
    # legend::Vector{Legend}
    # annotation::Vector{Annotation}
end

Plot( ; cascade, xaxis, yaxis, title, path) = Plot(cascade, [xaxis, yaxis], title, path)