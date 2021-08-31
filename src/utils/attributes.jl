"""
    wrap_to(str, width; scale)
This function wraps an input string `str` to the input `width`, calculated assuming a
font size `scale` and returns an array of strings.
"""
function wrap_to(str::String, width; scale)
    Luxor.@png begin
        tmp = Luxor.get_fontsize()
        Luxor.fontsize(FONTSIZE * scale)

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
    end

    return lst[.!isempty.(lst)]
end


wrap_to(x, args...; kwargs...) = wrap_to(string(x), args...; kwargs...)


"""
    _break(str)
This function breaks a string first at slashes (if any), and then at suffixes. 
"""
_break(str::String) = occursin("/",str) ? _break_slash(str) : _break_suffix(str)
_break(lst) = occursin("/",string(lst...)) ? _break_slash.(lst) : _break_suffix.(lst)


"""
    _break_suffix(str)
This function splits words' suffixes: '-ANT', '-ING', '-ION', after ensuring the input
string is uppercase.
"""
function _break_suffix(str)
    str = uppercase(str)
    suff = ["ANT","ING","ION"]

    rep = [
        Pair.(Regex.(suff.*"\\s"), string.("- ".*suff.*" "));
        Pair.(Regex.(suff.*"\$"), string.("- ".*suff));
    ]

    return reduce(replace, rep, init=str)
end


"""
    _break_slash(str)
This function splits words separated by a slash to allow line-breaking.
"""
_break_slash(str) = reduce(replace, [Pair(r"/", "/ ")], init=str)


"""
    set_hue!(x, h)
"""
function set_hue!(x::Coloring, h; kwargs...)
    x.hue = define_from(Luxor.RGB, h; kwargs...)
    return x
end

set_hue!(x::Blending, h) = begin x.hue = _define_gradient(h); return x end
set_hue!(x::T, h) where T<:Geometry = begin set_hue!(x.shape, h); return x end
set_hue!(x::T, h) where T<:Shape = begin set_hue!(x.color, h); return x end
set_hue!(x::Vector{T}, h) where T<:Shape = begin set_hue!.(x, h); return x end


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
    _define_alpha(N::Int; kwargs...)
This function calculates an alpha for `N` samples to scale transparency for overlays:

```math
\\alpha = \\min\\left\\lbrace\\dfrac{w}{f(N)},\\, 0\\right\\rbrace
```

# Keywords
- `factor::Real=0.25`, scaling weighting ``w``
- `fun::Function=log`, scaling function ``\\ln``
"""
function _define_alpha(N::Int; factor::Real=0.25, fun::Function=log, kwargs...)
    return min(factor/fun(N) ,1.0)
end

_define_alpha(x; kwargs...) = x


"""
    _define_gradient(x; kwargs...)
This method defines the starting and stopping colors for a color gradient, such that the
starting color is defined using [`Waterfall._define_colorant`](@ref) and the stopping color
is 50% "lighter" than this color.

# Returns
- `x::Tuple{Luxor.RGB,Luxor.RGB}`, color gradient from the starting to stopping pos of
    each waterfall in the cascade.
"""
function _define_gradient(x; kwargs...)
    lightness = 0.5
    h1 = define_from(Luxor.RGB, x)
    h2 = define_from(Luxor.RGB, x; lightness=lightness)
    return tuple(h1, h2)
end


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

Keywords:
- `on`, interval of maximum and minimum result values
"""
_scale_by(v, f; on, kwargs...) = (on[sign(f)<0 ? 1 : 2] - v) * abs(f) + v


"""
    scale_hsv(color; kwargs...)
This function decreases or increases `color` saturation by a factor of ``s \\in [-1,1]``.

# Keywords
- `lightness=0.5`, factor by which to "lighten" a color. Doing so scales hue by
    `h=lightness` and saturation by `s=-lightness`. Allowed values: ``\\in [0,1]``.
- `h=0`, factor by which to scale color hue. Allowed values: ``\\in [-1,1]``.
    `hsv.h` ``\\in [0,1]``
- `s=0`, factor by which to scale color saturation. Allowed values: ``\\in [-1,1]``.
    `hsv.s` ``\\in [0,1]``
- `v=0`, factor by which to scale color value. Allowed values: ``\\in [-1,1]``.
    `hsv.v` ``\\in [0,255]``.
"""
function scale_hsv(hsv::Luxor.HSV; lightness=missing, h=0, s=0, v=0, kwargs...)

    return if !ismissing(lightness)
        scale_hsv(hsv; s=-lightness, v=lightness)
    else
        h = _scale_by(hsv.h, h; on=[0,255])
        s = _scale_by(hsv.s, s; on=[0,1])
        v = _scale_by(hsv.v, v; on=[0,1])
        Luxor.Colors.HSV(h, s, v)
    end
end

function scale_hsv(rgb::Luxor.RGB; kwargs...)
    hsv = scale_hsv(convert(Luxor.HSV, rgb); kwargs...)
    rgb = convert(Luxor.RGB, hsv)
    return rgb
end


"""
"""
function _define_annotation(cascade::Cascade{Data}, Geometry::DataType, args...; kwargs...)
    txt = _define_text(cascade, args...; kwargs...)
    pos = _define_position(cascade, Geometry; kwargs...)
    return _define_from(Vector{Label{String}}, txt, pos; valign=:bottom, kwargs...)
end


function _define_annotation(cascade::Cascade{Data}, ::Type{Missing}; kwargs...)
    return fill(_define_from(Label, Missing), length(collect_data(cascade)))
end


"""
"""
function _define_from(::Type{T}, x::Tuple{Luxor.Point,Luxor.Point};
    hue = "black",
    alpha = 1.0,
    style = :stroke,
    kwargs...,
) where T <: Union{Arrow,Line}
    return T(x, _define_from(Coloring, hue; alpha=alpha), style)
end


"""
"""
function _define_ticks(cascade, ::Type{T};
    x = 0,
    y = HEIGHT,
    len = SEP,
    kwargs...,
) where T <: Axis

    p1 = _define_position(cascade, T; x=x-0.5*len, y=y-0.5*len, kwargs...)
    p2 = _define_position(cascade, T; x=x+0.5*len, y=y+0.5*len, kwargs...)

    return _define_from.(Line, tuple.(p1,p2))
end


"""
    _define_text(x::Float64; kwargs...)
This method formats `x` as a string.

# Keywords
- `digits=2`, fractional digits to include
- `sgn=true`, indicates whether to show a leading `+`

    _define_text(cascade, fun::Function, args...; kwargs...)
This method calculates a value 
"""
function _define_text(x::Float64; sgn=true, digits=2)
    x = round(x; digits=digits)
    sgn = sgn ? sgn : Base.sign(x)<0
    
    len = length(string(abs(convert(Int, round(x))))) + 1 + sgn
    str = sgn ? @Printf.sprintf("%+2.10f", x) : @Printf.sprintf("%2.10f", x)

    return string(str[1:len+digits])
end


function _define_text(cascade, fun::Function, args...; kwargs...)
    v = get_value(collect_data(cascade))
    v = calculate(v, fun, args...)

    digits = abs(minimum(get_order.(v))) + 1

    str = _define_text.(v; digits=digits)
    [str[ii] = str[ii][2:end] for ii in [1,size(str,1)]]

    return str
end


function _define_text(cascade, ::Type{YAxis}; scale=0.9, kwargs...)
    v = collect_ticks(cascade; kwargs...)
    digits = abs(minimum(get_order.(v)))
    return _define_text.(v; digits=digits, sgn=false)
end


function _define_text(cascade, ::Type{XAxis}, field::Symbol; kwargs...)
    return getfield.(collect_data(cascade), field)
end

_define_text(x) = x


"""
    _define_position(cascade, ::Type{T}; kwargs...) where T <: Axis
This method defines the TICK POSITIONS for the input Axis subtype (XAxis or YAxis).

# Arguments
- `cascade`

# Keywords
- `x=0`, x-coordinate of y-axis.
- `y=HEIGHT`, y-coordinate of x-axis.
"""
function _define_position(cascade, ::Type{YAxis};
    x = 0,
    xshift = 0,
    kwargs...,
)
    y = collect_ticks(cascade; kwargs...)
    y = scale_y(y; vlim(cascade; kwargs...)...)
    return Luxor.Point.(x+xshift, y)
end


function _define_position(cascade, ::Type{XAxis}, args...;
    y = HEIGHT,
    yshift = 0,
    kwargs...,
)
    x = scale_x( ; steps=length(collect_data(cascade)))
    return Luxor.Point.(x, y+yshift)
end


function _define_position(cascade, Geometry; kwargs...)
    x = scale_x( ; steps=length(collect_data(cascade)))
    
    pos = scale_for(cascade, Geometry; kwargs...)
    y = minimum.(pos; dims=2)
    return Luxor.Point.(x, y)
end


"""
    _define_from(::Type{Vector{L}}, ::Type{A}, cascade; kwargs...) where {L<:Label, A<:Axis}
    _define_from(::Type{Vector{L}}, ::Type{XAxis}, cascade, fun; kwargs...) where L<:Label
These methods define LABELS for the input `Axis` subtype (XAxis or YAxis).

# Arguments
- `cascade::Cascade`
- `field::Symbol`, if defining ticks for the XAxis, include the Data field name that will
    serve as the x-axis tick label or sublabel. Allowed options: `:label`, `:sublabel`.

# Returns
- `ticklabels::Vector{L}` of tick LABELS
- `ticksublabels::Vector{L}` (returned if `A=XAxis` and `fun` unspecified), of tick SUBLABELS
"""
function _define_from(::Type{Vector{T}}, cascade::Cascade{Data}, args...; kwargs...) where T <: Label
    txt = _define_text(cascade, args...; kwargs...)
    pos = _define_position(cascade, args...; kwargs...)
    return _define_from(Vector{T}, txt, pos; kwargs...)
end


function _define_from(::Type{T}, text, pos::Luxor.Point;
    scale = 1,
    halign = :center,
    valign = :middle,
    leading = 1,
    angle = 0,
    kwargs...,
) where T <: Label
    return Label( ;
        text = text,
        scale = scale,
        position = pos,
        halign = halign,
        valign = valign,
        angle = angle,
        leading = leading,
    )
end


function _define_from(::Type{T}, text::String, pos::Luxor.Point, width::Float64;
    scale = 1,
    kwargs...,
) where T <: Label
    return _define_from(T, wrap_to(text, width; scale), pos; kwargs...)
end


function _define_from(::Type{Vector{Label{T}}}, text::AbstractArray, pos::AbstractArray;
    kwargs...,
) where T <: Vector{String}
    N = length(pos)
    wid = width(N; space=2)
    return [_define_from(Label, text[ii], pos[ii], wid; kwargs...) for ii in 1:N]
end


function _define_from(::Type{Vector{Label{T}}}, text::AbstractArray, pos::AbstractArray;
    kwargs...,
) where T <: Any
    return [_define_from(Label{T}, text[ii], pos[ii]; kwargs...) for ii in 1:length(pos)]
end


function _define_from(::Type{T}, ::Type{Missing}; kwargs...) where T<:Label
    return _define_from(Label, missing, Luxor.Point(0,0))
end


"""
    _define_path(cascade::Cascade, Geometry; kwargs...)
This method defines the path to which to write the file:
    Geometry/Geometry_n<nsample>_colorcycle<0/1>_corr<0/1>_<permutation>.png
"""
function _define_path(x::Cascade, Geometry;
    colorcycle,
    ext = ".png",
    figdir = "fig",
    maxsample = 50,
    kwargs...,
)
    separator = "_"
    Geometry = lowercase(string(Geometry))

    # Define the path name and create the directory if it doesn't already exist.
    path = joinpath(WATERFALL_DIR, figdir, Geometry)

    if !isdir(path)
        @info("Creating directory: $path")
        mkpath(path)
    end

    str = joinpath(path, join([
        Geometry,
        "n" * _define_path(length(x); maxchar=get_order(maxsample)+1), # number of samples
        _define_path(get_label.(x.steps); kwargs...),                  # labels, in order
        "corr"       * _define_path(x.iscorrelated),                   # is it correlated?
        "colorcycle" * _define_path(colorcycle),                       # colorscheme?
        ], separator,
    ) * ext)

    println("Writing plot: $str")
    return str
end


function _define_path(lst::Vector{String}; maxchar=missing, kwargs...)
    maxchar = coalesce(maxchar, maximum(length.(lst)))
    lst = _define_path.(tryinteger(lst); maxchar=maxchar)
    return join(lst, maxchar>1 ? "-" : "")
end


_define_path(x::Int; maxchar=1) = string(Printf.@sprintf("%010.0f", x)[end-(maxchar-1):end])
_define_path(x::Bool; kwargs...) = string(convert(Int, x))
_define_path(x::String; kwargs...) = x


"""
    _define_title(cascade::Cascade{Data}; kwargs...)
This method formats a title to describe, where applicable:
1. The number of samples,
2. Range of correlation coefficients (if a correlation was applied), and
3. The distribution function (normal or uniform) used to create samples
    (if more than one sample).
"""
function _define_title(cascade::Cascade{Data}; nsample,
    titlescale = 1.1,
    titleleading = 1.1,
    kwargs...,
)
    # Select which rows of the title to show:
    # (1) Always show the number of samples,
    # (2) Show correlation range if one is applied,
    # (3) Show sample distribution if multiple samples are given.
    idx = [true, cascade.iscorrelated, nsample>1]

    str = [
        "$nsample SAMPLE" * (nsample>1 ? "S" : ""),
        _title_correlation( ; kwargs...),
        _title_distribution( ; kwargs...)
    ][idx]

    return Label( ; 
        text = str,
        scale = titlescale,
        position = Luxor.Point(WIDTH/2, -TOP_BORDER),
        halign = :center,
        valign = :middle,
        angle = 0,
        leading = titleleading,
    )
end


"Format title string for normal distribution function"
_title_normal(x) = "f(x; $(x[1]) < \\sigma < $(x[2]))"


"Format title string for uniform distribution function"
function _title_uniform(x; abs::Bool=false)
    abs = abs ? "|" : ""
    return "f($(abs)x$(abs); a>$(x[1]), b<$(x[2]))"
end


"Format title string for SAMPLE distribution"
function _title_distribution( ; distribution, fuzziness, kwargs...)
    str = uppercase("$distribution sample distribution: ")

    return if distribution==:normal; str * _title_normal(fuzziness)
    elseif distribution==:uniform;   str * _title_uniform(fuzziness)
    else; ""
    end
end


"Format title string for correlation coefficient"
function _title_correlation( ; interactivity, kwargs...)
    return "CORRELATION COEFFICIENT: " * _title_uniform(interactivity; abs=true)
end