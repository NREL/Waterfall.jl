mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    xaxis::Axis
    yaxis::Axis
end


Plot( ; cascade, xaxis, yaxis) = Plot(cascade, xaxis, yaxis)


function Plot(cascade::Cascade{Data}; xlabel="", ylabel, kwargs...)
    data = collect_data(cascade)
    xaxis = set_xaxis(data; label=xlabel)
    yaxis = set_yaxis(data; label=ylabel)
    return Plot(cascade, xaxis, yaxis)
end


function Plot{T}(p::Plot{Data}, args...; kwargs...) where T<:Points
    return Plot(Cascade{T}(p.cascade, args...; kwargs...), p.xaxis, p.yaxis)
end


get_cascade(x::Plot) = x.cascade
get_xaxis(x::Plot) = x.xaxis
get_yaxis(x::Plot) = x.yaxis