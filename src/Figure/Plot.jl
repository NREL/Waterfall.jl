mutable struct Plot{T<:Sampling}
    cascade::Cascade{T}
    legend::Vector{Pair{Handle,Any}}
    axes::Vector
    title::Label{Vector{String}}
    path::String
    # xaxis::Axis
    # yaxis::Axis
    # legend::Vector{Legend}
    # annotation::Vector{Annotation}
end

function Plot( ; cascade, legend, xaxis, yaxis, title, path)
    return Plot(cascade, legend, [xaxis, yaxis], title, path)
end
