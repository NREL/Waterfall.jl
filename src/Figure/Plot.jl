mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    xaxis::Axis
    yaxis::Axis
    # legend::Vector{Legend}
    # annotation::Vector{Annotation}
end


Plot( ; cascade, xaxis, yaxis) = Plot(cascade, xaxis, yaxis)
# function Waterfall.Plot( ; cascade, xaxis=Axis(), yaxis=Axis(), kwargs...)
    # x = Plot(cascade, xaxis, yaxis)
    # return Plot(cascade, xaxis, yaxis)
    # legend=Vector{Legend}(),
    # annotation=Vector{Annotation}(),
    # return Plot(Cascade, xaxis, yaxis, legend, annotation)
# end


function Plot(cascade::Cascade{Data}; kwargs...)
    xaxis = set_xaxis(cascade; kwargs...)
    yaxis = set_yaxis(cascade; kwargs...)
    return Plot(cascade, xaxis, yaxis)
end


"""
"""
function set_xaxis(data::Vector{Data}; xlabel="", kwargs...)
    N = length(data)
    xticklabels = Waterfall.get_label.(data)
    xticksublabels = Waterfall.get_sublabel.(data)
    xticks = Waterfall.cumulative_x(; steps=N)
    return Axis( ; label=xlabel, ticklabels=xticklabels, ticksublabels=xticksublabels, ticks=xticks, lim=(1,N))
end

set_xaxis(args...; kwargs...) = _set_axis(set_xaxis, args...; kwargs...)


"""
"""
function set_yaxis(data::Vector{Data}; ylabel, kwargs...)
    vlims = Waterfall.vlim(data)
    vmin, vmax, vscale = vlims
    yticklabels = collect(vmin:floor(vmax))
    yticks = scale_y(yticklabels; vlims...)
    return Axis( ; label=ylabel, ticklabels=yticklabels, ticks=yticks, lim=(vmin,vmax))
end

set_yaxis(args...; kwargs...) = _set_axis(set_yaxis, args...; kwargs...)



_set_axis(fun::Function, x::Cascade, args...; kwargs...) = fun(Waterfall.collect_data(x); kwargs...)