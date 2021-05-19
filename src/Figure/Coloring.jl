mutable struct Coloring
    hue::Luxor.RGB
    saturation::Float64
    opacity::Float64
end


function Coloring(rgb::Luxor.Colorant; saturation=0.0, opacity=1.0, kwargs...)
    return Coloring(scale_saturation(rgb, saturation), saturation, opacity)
end

function Coloring(x::T; hue=missing, opacity=missing, kwargs...) where T <: Points
    hue = _hue(hue, x)
    opacity = _opacity(opacity, x; kwargs...)
    return Coloring.(hue; opacity=opacity, kwargs...)
end

Coloring(hue::String; kwargs...) = Coloring(parse(Luxor.Colorant, hue); kwargs...)


# "This function returns the hue associated with whether the value is a gain or loss."
_hue(sign::Integer) = sign<0 ? HEX_LOSS : HEX_GAIN
_hue(value::Missing, x::T) where T<:Points = _hue.(x.sign)
_hue(value, x::T) where T<:Points = fill(value, length(x))

_opacity(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = factor/fun(N)
_opacity(value::Missing, x::T; kwargs...) where T<:Points = _opacity(length(x); kwargs...)
_opacity(value, x::T; kwargs...) where T <:Points = value