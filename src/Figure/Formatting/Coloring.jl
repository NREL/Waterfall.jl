mutable struct Coloring
    hue::Luxor.RGB
    alpha::Float64
    saturation::Float64
end


# set_hue!(x, h) = begin x.hue = _set_hue(h); return x end
# set_hue!(x::T, h) where T<:Box = begin set_hue!(x.color, h); return x end
# set_hue!(x::Vector{T}, h) where T<:Box = begin set_hue!.(x, h); return x end
# set_hue!(x::T, h) where T<:AbstractArray = begin set_hue!.(x, h); return x end

# set_alpha!(x, a) = begin x.alpha = _set_alpha(a); return x end

# set_saturation!(x, s) = begin x.saturation=s; return x end

# set_color!(x::T, c) where T<:Box = begin x.color = c; return x end



# """
#     coloring()
# Returns Coloring struct with defaults:

# """
# function Coloring( ; hue, alpha=0.8, saturation=1.0, kwargs...)
#     return Coloring(_hue(hue), _alpha(alpha), saturation)
# end


function _set_coloring( ; hue, alpha=0.8, saturation=1.0, kwargs...)
    return Coloring(_set_hue(hue; kwargs...), _set_alpha(alpha), saturation)
end

_set_coloring(x::Coloring; kwargs...) = x


"""
    hue(x)
"""
_set_hue(x; kwargs...) = parse(Luxor.Colorant, x)
_set_hue(idx::Integer; kwargs...) = _set_hue(COLORCYCLE[idx]; kwargs...)
_set_hue(sgn::Float64; kwargs...) = _set_hue(sgn > 0 ? HEX_LOSS : HEX_GAIN)

function _set_hue(point::Tuple{Luxor.Point,Luxor.Point}; index=missing, kwargs...)
    return if ismissing(index)
        _set_hue(sign(point[2][2] - point[1][2]); kwargs...)
    else
        _set_hue(index)
    end
end


"""
    _set_alpha(x)
"""
_set_alpha(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = min(factor/fun(N),1.0)
_set_alpha(x) = x




# function Coloring(x::T; hue=missing, opacity=missing, kwargs...) where T <: Geometry
#     hue = _hue(hue, x)
#     opacity = _opacity(opacity, x; kwargs...)
#     return Coloring.(hue; opacity=opacity, kwargs...)
# end


# Coloring(hue::String; kwargs...) = Coloring(parse(Luxor.Colorant, hue); kwargs...)


# # "This function returns the hue associated with whether the value is a gain or loss."
# _hue(sign::Integer) = sign<0 ? HEX_LOSS : HEX_GAIN
# _hue(value::Missing, x::T) where T<:Geometry = _hue.(x.sign)
# _hue(value, x::T) where T<:Geometry = fill(value, length(x))

# _hue(value, x::Violin) = value

# function _hue(value::Missing, x::Violin)
#     hue = _hue.(x.sign)
#     c = parse.(Luxor.Colorant, hue)
#     cavg = [Statistics.mean(getproperty.(c, f)) for f in fieldnames(Luxor.RGB)]
#     return Luxor.Colors.RGB(cavg...)
# end


# _opacity(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = factor/fun(N)
# _opacity(value::Missing, x::T; kwargs...) where T<:Geometry = _opacity(length(x); kwargs...)
# _opacity(value, x::T; kwargs...) where T <:Geometry = value



