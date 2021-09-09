mutable struct Plot{T<:Sampling}
    cascade::Cascade{T}
    legend::Vector{Pair{Handle,Any}}
    axes::Vector
    title::Label{Vector{String}}
    path::String
end

function Plot( ; cascade, legend, xaxis, yaxis, title, path)
    return Plot(cascade, legend, [xaxis, yaxis], title, path)
end
