set_hue!(x::Coloring, h) = begin x.hue = _set_hue(h); return x end
set_hue!(x::T, h) where T<:Shape = begin set_hue!(x.color, h); return x end
set_hue!(x::T, h) where T<:Geometry = begin set_hue!.(x.attribute, h); return x end
set_hue!(x::Vector{T}, h) where T<:Box = begin set_hue!.(x, h); return x end
# set_hue!(x::T, h) where T<:AbstractArray = begin set_hue!.(x, h); return x end

set_alpha!(x, a) = begin x.alpha = _set_alpha(a); return x end

set_saturation!(x, s) = begin x.saturation=s; return x end

# """
# """
# function set_data(Geometry::DataType, cascade::Cascade, args...; kwargs...)
#     points = Geometry==Violin ? scale_kde(cascade) : scale_point(cascade, args...; kwargs...)
    
#     start = define_from(Geometry, first(points); hue="black", kwargs...)
#     stop = define_from(Geometry, last(points); hue="black", kwargs...)
#     steps = define_from(Geometry, points[2:end-1]; kwargs...)
#     attr = [[start]; steps; [stop]]
    
#     label = get_label.(collect_data(cascade))
#     data = Geometry.(label, attr)

#     return Cascade(first(data), last(data), data[2:end-1], cascade.ncor, cascade.permutation, cascade.correlation)
# end


"""
    define_from()
"""



# """
# # Keyword arguments:
# - For alpha:
#     - `factor::Real=0.25`
#     - `fun::Function=log`
# - Defining style and dash
#     - style=:stroke (could also be a float)
# """
# function _define_from(Geometry::DataType, Shape::DataType, position::T, N::Integer;
#     kwargs...,
# ) where T <: Tuple
#     alpha = _set_alpha(N; kwargs...)
#     color = _set_color(Geometry, position; alpha=alpha, kwargs...)
#     return Shape( ; position=position, color=color, kwargs...)
# end

# function _define_from(Geometry, Shape, points::Vector{T}; kwargs...) where T <: Tuple
#     return _define_from.(Geometry, Shape, points, length(points); kwargs...)
# end

# function _define_from(Geometry, Shape, points::AbstractArray; kwargs...)
#     return _define_from.(Geometry, Shape, points; kwargs...)
# end












# """
#     set_color()
# """
# function _set_color(::Type{Horizontal}, position::T; hue=missing, kwargs...) where T <: Tuple
#     hue = _set_hue(ismissing(hue) ? position : hue; kwargs...)
#     return _set_coloring( ; hue=hue, kwargs...)
# end

# function _set_color(::Type{Vertical}, position::T; hue=missing, kwargs...) where T <: Tuple
#     hue = _set_hue(ismissing(hue) ? position : hue)
#     return _set_coloring( ; hue=hue, kwargs...)
# end

# function _set_color(::Type{Parallel}, position::T; hue=missing, kwargs...) where T <: Tuple
#     hue = _set_hue(ismissing(hue) ? position : hue)
#     return _set_coloring( ; hue=hue, kwargs...)
# end


# function _set_color(::Type{T}, lst::AbstractArray; kwargs...) where T <: Geometry
#     return _set_color.(T, lst; kwargs...)
# end


# """
#     set_hue()
# """
# function calculate_hue(point::Tuple{Luxor.Point,Luxor.Point})
#     result = !(point[2][2] > point[1][2]) ? HEX_GAIN : HEX_LOSS
#     return parse(Luxor.Colorant, result)
# end


# """
# """
# function scale_saturation(rgb::Luxor.RGB, args...)
#     hsv = scale_saturation(Luxor.convert(Luxor.Colors.HSV, rgb), args...)
#     return Luxor.convert(Luxor.Colors.RGB, hsv)
# end

# function scale_saturation(hsv::Luxor.HSV, f=0.0)
#     if f!==0.0
#         saturation = f<0 ? hsv.s * (1+f) : (1-hsv.s)*f + hsv.s
#         hsv = Luxor.Colors.HSV(hsv.h, saturation, hsv.v)
#     end
#     return hsv
# end





# """
# """
# makealpha(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = factor/fun(N)





# """
# """
# function set_style(dash::T) where T <: Real
#     dmin = 0.5
#     factor = 10

#     dash = (1-dmin)*dash + dmin
#     return factor*[dash, 1-dash]
# end

# set_style(s::Symbol) = s






# # makealpha(vec::AbstractVector; kwargs...) = fill(makealpha(length(vec); kwargs...), size(vec))
# # makealpha(mat::Matrix; kwargs...) = convert(Matrix, makealpha.(vectorize(mat); kwargs...))








# # set_style(attr::T) where T <: Shape





# # # "This function returns the hue associated with whether the value is a gain or loss."



# # convert(Matrix, makealpha.(vectorize(v)))



# # _hue(x::T) where T <: Real = sign(x)<0 ? parse(Luxor.Colorant, HEX_LOSS) : parse(Luxor.Colorant, HEX_GAIN)
# # _hue(lst::T) where T <: AbstractArray = _hue.(lst)

# # makealpha(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...) = factor/fun(N)
# # makealpha(vec::AbstractVector; kwargs...) = fill(makealpha(length(vec); kwargs...), size(vec))
# # makealpha(mat::Matrix; kwargs...) = convert(Matrix, makealpha.(vectorize(mat); kwargs...))


# # # SATURATION ONLY FOR BLENDING.
# # function format(::Type{Horizontal}, vec::AbstractArray)
# #     return Coloring.(_hue(vec), 1.0, makealpha(v; kwargs...))
# # end

# # format(::Type{T}, data::Data) where T <: Geometry = format(T, get_value(data))


# # function attribute(::Type{Horizontal}, vec::AbstractArray; style=:fill, dash=[], kwargs...)
# #     return [Box(c, style, dash) for c in format(Horizontal, vec)]
# # end

# # attribute(::Type{T}, data::Data) where T <: Geometry = attribute(T, get_value(data))



