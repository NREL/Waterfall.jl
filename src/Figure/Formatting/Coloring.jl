mutable struct Coloring
    hue::Luxor.RGB
    saturation::Float64
    opacity::Float64
end


function Coloring(rgb::Luxor.Colorant; saturation=0.0, opacity=1.0, kwargs...)
    return Coloring(scale_saturation(rgb, saturation), saturation, opacity)
end

function Coloring(x::T; hue=missing, opacity=missing, kwargs...) where T <: Geometry
    hue = _hue(hue, x)
    opacity = _opacity(opacity, x; kwargs...)
    return Coloring.(hue; opacity=opacity, kwargs...)
end


Coloring(hue::String; kwargs...) = Coloring(parse(Luxor.Colorant, hue); kwargs...)


# "This function returns the hue associated with whether the value is a gain or loss."
_hue(sign::Integer) = sign<0 ? HEX_LOSS : HEX_GAIN
_hue(value::Missing, x::T) where T<:Geometry = _hue.(x.sign)
_hue(value, x::T) where T<:Geometry = fill(value, length(x))

_hue(value, x::Violin) = value

function _hue(value::Missing, x::Violin)
    hue = _hue.(x.sign)
    c = parse.(Luxor.Colorant, hue)
    cavg = [Statistics.mean(getproperty.(c, f)) for f in fieldnames(Luxor.RGB)]
    return Luxor.Colors.RGB(cavg...)
end


_opacity(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = factor/fun(N)
_opacity(value::Missing, x::T; kwargs...) where T<:Geometry = _opacity(length(x); kwargs...)
_opacity(value, x::T; kwargs...) where T <:Geometry = value



function scale_saturation(rgb::Luxor.RGB, args...)
    hsv = scale_saturation(Luxor.convert(Luxor.Colors.HSV, rgb), args...)
    return Luxor.convert(Luxor.Colors.RGB, hsv)
end

function scale_saturation(hsv::Luxor.HSV, f=0.0)
    if f!==0.0
        saturation = f<0 ? hsv.s * (1+f) : (1-hsv.s)*f + hsv.s
        hsv = Luxor.Colors.HSV(hsv.h, saturation, hsv.v)
    end
    return hsv
end