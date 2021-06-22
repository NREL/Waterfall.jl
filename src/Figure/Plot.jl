mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    xaxis::Axis
    yaxis::Axis
    # legend::Vector{Legend}
    # annotation::Vector{Annotation}
end


function Plot( ;
    cascade,
    xaxis, 
    yaxis,
    # legend=Vector{Legend}(),
    # annotation=Vector{Annotation}(),
    kwargs...,
)
    # return Plot(Cascade, xaxis, yaxis, legend, annotation)
    return Plot(cascade, xaxis, yaxis)
end


function Plot(cascade::Cascade{Data}; xlabel="", ylabel, show_permutation=true, kwargs...)
    # if show_permutation
    #     idx = Waterfall.collect_permutation(cascade)
    #     data = Waterfall.collect_data(cascade)[idx]
    # end

    data = Waterfall.collect_data(cascade)
    xaxis = Waterfall.set_xaxis(data; label=xlabel)
    yaxis = Waterfall.set_yaxis(data; label=ylabel)

    return Plot( ; cascade=cascade, xaxis=xaxis, yaxis=yaxis)
    # return Plot( ; cascade=convert(Cascade{T}, cascade), xaxis=xaxis, yaxis=yaxis)
end