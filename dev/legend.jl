"""
    get_shape(cascade; kwargs...)
This function returns the shape used in `cascade`, with its position updated, as defined by
keyword arguments.
"""
function get_shape(cascade::Cascade{T};
    x0 = WIDTH-100,
    y0 = 3*SEP,
    dx = 2*SEP,
    space,
    idx = 1,
    kwargs...,
) where T<:Geometry
    y0 = y0 + FONTSIZE*(idx-1)
    shape = copy(first(cascade.start.shape))
    setproperty!(shape, :position, (Luxor.Point(x0-dx, y0+space), Luxor.Point(x0+dx, y0-space)))
    return shape
end


"""
    _define_from(Handle, cascade, fun, args...)
"""
function _define_from(::Type{Handle}, cascade::Cascade{T}, fun::Function, args...;
    space = SEP,
    kwargs...,
) where T <: Geometry
    shape = get_shape(cascade; space=space, kwargs...)
    label =_define_from(Label, string(fun), last(shape.position.+space); halign=:left)
    return Handle(shape, label)
end


function _define_from(::Type{Handle}, cascade::Cascade{T}, hue, str;
    idx = 1,
    space = SEP,
    kwargs...,
) where T <: Geometry
    shape = copy(get_shape(cascade; idx=idx, space=space, kwargs...))
    label =_define_from(Label, str, last(shape.position.+space); halign=:left)
    return Handle(set_hue!(shape, hue), label)
end


function _define_from(::Type{Handle}, cascade::Cascade{T};
    colorcycle,
    kwargs...,
) where T <: Geometry

    return [_define_from(Handle, cascade, hue, str; idx=idx, kwargs...)
        for (idx, hue, str) in zip(1:2, [HEX_GAIN,HEX_LOSS], ["GAIN","LOSS"])]

end

# perm = [2,1,3,4]
# fun = Statistics.mean
# # h = _define_from(Handle, plot.cascade, fun; locals..., kwargs...)
# h = _define_from(Handle, plot.cascade; locals..., kwargs...)