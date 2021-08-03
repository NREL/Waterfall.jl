function _define_label(str::String, width; font)
    tmp = Luxor.get_fontsize()
    Luxor.fontsize(font)

    str = uppercase(str)
    lst = Luxor.textlines.(Luxor.textlines(str, width), width)

    idx = .!.&(isempty.(getindex.(lst,1)), length.(lst).==1)
    lst = lst[idx]

    idx = length.(lst).==2

    if any(idx)
        lst[idx] = Luxor.textlines.(_break(getindex.(lst[idx],2)), width)
        lst = vcat(lst...)
        lst = Luxor.textlines(string(lst[.!isempty.(lst)] .* " "...), width)
    else
        lst = vcat(lst...)
    end
    
    lst = vcat(lst...)
    Luxor.fontsize(tmp)

    return lst[.!isempty.(lst)]
end


_break(str) = occursin("/",str) ? _break_slash(str) : _break_suffix(str)

function _break(lst::AbstractVector)
    return occursin("/",string(lst...)) ? _break_slash.(lst) : _break_suffix.(lst)
end

function _break_suffix(str)
    suff = ["ANT","ING","ION"]
    # rep = Pair.(Regex.(suff), string.("- ".*suff))
    rep = [
        Pair.(Regex.(suff.*"\\s"), string.("- ".*suff.*" "));
        Pair.(Regex.(suff.*"\$"), string.("- ".*suff));
    ]

    return reduce(replace, rep, init=str)
end

_break_slash(str) = reduce(replace, [Pair(r"/", "/ ")], init=str)










function set_hue!(x::Coloring, h)
    x.hue = scale_saturation(_set_hue(h); saturation=x.saturation)
    return x
end

set_hue!(x::T, h) where T<:Geometry = begin set_hue!(x.attribute, h); return x end

set_hue!(x::T, h) where T<:Shape = begin set_hue!(x.color, h); return x end
set_hue!(x::Vector{T}, h) where T<:Box = begin set_hue!.(x, h); return x end
# set_hue!(x::Vector{T}, h) where T<:Poly = begin set_hue!.(x, h); return x end

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




rgb = Luxor.RGB(0,0,0)
sat = -0.2


hsv = Luxor.convert(Luxor.Colors.HSV, rgb)



function set_hue!(x::Blending, h)
    set_hue!(x.color1, h)
    set_hue!(x.color2, h)
    return x
end




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