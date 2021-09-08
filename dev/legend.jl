"""
"""
function set_position!(handle::Handle;
    x0 = WIDTH-100,
    y0 = 3*SEP,
    dx = 2*SEP,
    space = SEP,
    idx = 1,
    kwargs...,
)
    y0 = y0 + 2.5*space*(idx-1)
    
    setproperty!(handle.shape, :position, (
        Luxor.Point(x0-dx, y0+space),
        Luxor.Point(x0+dx, y0-space)),
    )
    
    setproperty!(handle.label, :position, last(handle.shape.position.+space))

    return handle
end


"""
    get_shape(cascade; kwargs...)
This function returns the shape used in `cascade`, with its position updated, as defined by
keyword arguments.
"""
get_shape(cascade::Cascade{T}) where T<:Geometry = copy(first(cascade.start.shape))


"""
    _define_from(Handle, cascade, fun, args...)
"""
function _define_from(::Type{Handle}, cascade::Cascade{T}, str::String;
    scale = 0.8,
    kwargs...,
) where T <: Geometry
    shape = get_shape(cascade)
    label = _define_from(Label, str, Luxor.Point(0,0); halign=:left, scale=scale)
    return set_position!(Handle(shape, label); scale=scale, kwargs...)
end


function _define_from(::Type{Handle}, cascade, fun::Function, args...; kwargs...)
    return _define_from(Handle, cascade, string(fun); kwargs...)
end


function _define_from(::Type{Handle}, cascade, str::String, hue; kwargs...)
    h = _define_from(Handle, cascade, str; kwargs...)
    return set_hue!(h, hue)
end


function _define_from(::Type{Handle}, cascade; colorcycle, kwargs...)
    return [_define_from(Handle, cascade, str, hue; idx=idx, kwargs...)
        for (idx, str, hue) in zip(1:2, ["GAIN","LOSS"], [HEX_GAIN,HEX_LOSS])]
end


"""
    _define_from(Annotation)
"""
function _define_from(::Type{Annotation}, cascade::Cascade{Data}, Geometry::DataType,
    args...;
    scale = 0.8,
    kwargs...,
)
    return Annotation(
        label = _define_label(cascade, Geometry, args...; scale=scale, kwargs...),
        cascade = set_geometry(cascade, Geometry, args...; alpha=1.0, style=:stroke, kwargs...),
    )
end


"""
    _define_legend(cascade; kwargs)
"""
function _define_legend(cascade::Cascade{T}; kwargs...) where T <: Geometry
    legend = _define_from(Handle, cascade; kwargs...) .=> missing
    return legend |> Vector{Pair{Handle,Any}}
end


"""
    _push!(legend, cascade, Geometry, args...; kwargs...)

# Arguments
- `legend`
- `cascade::Cascade{Data}`
- `fun::Function`
"""
function _push!(
    legend::Vector{Pair{Handle,T}},
    cascade::Cascade{Data},
    Geometry::DataType,
    args...;
    kwargs...,
) where T<:Any
    a =  _define_from(Annotation, cascade, Geometry, args...; kwargs...)
    h = _define_from(Handle, a.cascade, args...; idx=length(legend)+1, kwargs...)
    push!(legend, h => a)
    return legend
end