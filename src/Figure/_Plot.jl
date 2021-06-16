mutable struct Annotation
    label::Union{String,Tuple}
    cascade::Cascade{Horizontal}
end


mutable struct Plot{T <: Sampling}
    cascade::Cascade{T}
    xaxis::Axis
    yaxis::Axis
    legend::Vector{Legend}
    annotation::Vector{Annotation}
end

function Plot( ; cascade, xaxis, yaxis, legend=Vector{Legend}(), annotation=Vector{Annotation}())
    return Plot(cascade, xaxis, yaxis, legend, annotation)
end


"""
    Plot( ; kwargs...)
This method allows for field order-independent Plot-definition.

# Keyword arguments
- `cascade::Cascade{T}`
- `xaxis::Axis`
- `yaxis::Axis`
- `legend::Vector{Legend}=Vector{Legend}()`


    Plot(cascade::Cascade{Data}; kwargs...)

# Keyword arguments
- `xlabel::String=""`
- `ylabel`

# Returns
- `plot::Plot{Data}`


    Plot{T}(plot::Plot{Data})
This method defines a plot of type `Plot{T} where T<:Geometry` from a plot of type `Plot{Data}`
"""
# Plot( ; cascade, xaxis, yaxis, legend=Vector{Legend}) = Plot(cascade, xaxis, yaxis, legend)


function Plot(df::DataFrames.DataFrame; ylabel::Symbol=:Units, kwargs...)
    cascade = Cascade(df; kwargs...)
    data = collect_data(cascade)
    set_order!(cascade, sortperm(get_value(cascade.start)))

    return Plot(cascade; ylabel=first(unique(df[:,ylabel])), kwargs...)
end


function Plot(cascade::Cascade{Data}; xlabel="", ylabel, kwargs...)
    data = collect_data(cascade)
    xaxis = set_xaxis(data; label=xlabel)
    yaxis = set_yaxis(data; label=ylabel)
    return Plot( ; cascade=cascade, xaxis=xaxis, yaxis=yaxis)
end


function Plot{T}(p::Plot{Data}, args...; kwargs...) where T<:Geometry
    return Plot(Cascade{T}(p.cascade, args...; kwargs...), p.xaxis, p.yaxis, p.legend, p.annotation)
    # return Plot(Cascade{T}(p.cascade, args...; kwargs...), p.xaxis, p.yaxis)
end


# function Base.convert(::Plot{T}, p::Plot{Data}, args...; kwargs...) where T <: Geometry
#     return Plot(Cascade{T}(p.cascade, args...; kwargs...), p.xaxis, p.yaxis)
# end


get_cascade(x::Plot) = x.cascade
get_xaxis(x::Plot) = x.xaxis
get_yaxis(x::Plot) = x.yaxis

set_cascade!(x::Plot, cascade) = begin x.cascade = cascade; return x end