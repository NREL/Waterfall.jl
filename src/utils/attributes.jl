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









"""
    set_hue!(x, h)
"""
function set_hue!(x::Coloring, h; kwargs...)
    x.hue = define_from(Luxor.RGB, h; kwargs...)
    return x
end

function set_hue!(x::Blending, h)
    lightness = 0.5
    x.hue = (
        define_from(Luxor.RGB, h),
        define_from(Luxor.RGB, h; s=-lightness, v=lightness),
    )
    return x
end

set_hue!(x::T, h) where T<:Geometry = begin set_hue!(x.attribute, h); return x end
set_hue!(x::T, h) where T<:Shape = begin set_hue!(x.color, h); return x end
set_hue!(x::Vector{T}, h) where T<:Box = begin set_hue!.(x, h); return x end


"""
"""
function define_from(::Type{T}, x; kwargs...) where T <: Luxor.Colorant
    return scale_hsv(parse(T, _define_colorant(x)); kwargs...)
end


"""
    _define_colorant(idx::Int)
This method returns the color defined at index `idx` of `COLORCYCLE`

    _define_colorant(sgn::Float64)
This method returns
- **Red**, given a negative value or
- **Blue**, given a positive value.

    _define_colorant(lst::AbstractVector)
This method returns an average of the colors defined in the `lst`
"""
function _define_colorant(lst::AbstractVector)
    rgb = _define_colorant.(lst)
    rgb_average = [Statistics.mean(getproperty.(rgb, f)) for f in fieldnames(Luxor.RGB)]
    return Luxor.Colors.RGB(rgb_average...)
end

_define_colorant(idx::Int) = COLORCYCLE[idx]
_define_colorant(sgn::Float64) = sign(sgn)>0 ? HEX_GAIN : HEX_LOSS
_define_colorant(x) = parse(Luxor.Colorant, x)


"""
    _define_alpha(x::Int; kwargs...)
"""
function _define_alpha(N::Integer; factor::Real=0.25, fun::Function=log, kwargs...)
    return min(factor/fun(N) ,1.0)
end

_define_alpha(x; kwargs...) = x


"""
This method scales a value ``v \\in [0,1]`` by a factor ``f \\in [-1,1]``,
``f<0`` decreases ``v`` and ``f>0`` increases ``v``:
```math
v' =
\\begin{cases}
\\left(v-v_{min}\\right) f + v & f<0
\\\\
\\left(v_{max}-v\\right) f + v
\\end{cases}
```
"""
_scale_by(v, f; on, kwargs...) = (on[sign(f)<0 ? 1 : 2] - v) * abs(f) + v


"""
    scale_hsv(color; s=0)
This function decreases or increases `color` saturation by a factor of ``s \\in [-1,1]``.
"""
function scale_hsv(hsv::Luxor.HSV; h=0, s=0, v=0, kwargs...)
    h = _scale_by(hsv.h, h; on=[0,255])
    s = _scale_by(hsv.s, s; on=[0,1])
    v = _scale_by(hsv.v, v; on=[0,1])
    return Luxor.Colors.HSV(h, s, v)
end

function scale_hsv(rgb::Luxor.RGB; kwargs...)
    hsv = scale_hsv(convert(Luxor.HSV, rgb); kwargs...)
    rgb = convert(Luxor.RGB, hsv)
    return rgb
end





"""
"""
function _define_annotation(cascade::Cascade{Data}, Geometry::DataType;
    textsize=0.9,
    kwargs...,
)
    # Define label text.
    fun = Statistics.mean
    v = get_value(collect_data(cascade))
    vlab = calculate(v, fun; dims=2)
    lab = [@Printf.sprintf("%+2.2f",x) for x in vlab]
    N = size(v,1)

    # Remove sign from start, stop:
    [lab[ii] = string(lab[ii][2:end-1]) for ii in [1,N]]
    lab = vectorize(lab)

    # Define position
    wid = width(N)

    # Define x position.
    xmid = cumulative_x( ; steps=N)

    # Define y position.
    position = _calculate_position(cascade, Geometry; kwargs...)
    ymin = minimum.(position; dims=2) .- LEADING*textsize*length.(lab) .- 0.5*SEP

    return Label.(lab, textsize, wid, Luxor.Point.(xmid,ymin), :center)
end







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