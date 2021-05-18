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


function Plot{T}(p::Plot{Data}, args...) where T <: Union{Vertical,Horizontal}
    return Plot(Cascade{T}(p.cascade, args...), p.xaxis, p.yaxis)
end


function Plot{T}(p::Plot{Data}; kwargs...) where T <: Union{Scatter,Violin}
    return SplitPlot{T,T}(p)
end


get_cascade(x::Plot) = x.cascade
get_xaxis(x::Plot) = x.xaxis
get_yaxis(x::Plot) = x.yaxis

# function Plot{T}(x::Cascade{Data}; kwargs...) where T <: Union{Scatter,Violin}
#     return SplitPlot{T,T}(Plot(x; kwargs...))
# end


# function Plot{T}(x::Cascade{Data}, args...; kwargs...) where T <: Union{Vertical,Horizontal}
#     p = Plot(x; kwargs...)
#     return Plot(Cascade{T}(p.cascade, args...), p.xaxis, p.yaxis)
# end