mutable struct Plot2{T <: Sampling}
    Cascade2::Cascade2{T}
    xaxis::Axis
    yaxis::Axis
    legend::Vector{Legend}
    annotation::Vector{Annotation}
end


function Plot2( ;
    Cascade2,
    xaxis, 
    yaxis,
    legend=Vector{Legend}(),
    annotation=Vector{Annotation}(),
    kwargs...,
)
    return Plot2(Cascade2, xaxis, yaxis, legend, annotation)
end


function Plot2{T}(cascade::Cascade2{Data}; xlabel="", ylabel, kwargs...) where T <: Geometry
    data = collect_data(cascade)
    xaxis = set_xaxis(data; label=xlabel)
    yaxis = set_yaxis(data; label=ylabel)

    return Plot2( ; cascade=convert(Cascade2{T}, cascade), xaxis=xaxis, yaxis=yaxis)
end