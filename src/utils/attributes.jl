"""
    wrap_to(str, width; textscale)
This function wraps an input string `str` to the input `width`, calculated assuming a
font size `textscale` and returns an array of strings.
"""
function wrap_to(str::String, width; textscale)
    Luxor.@png begin
        tmp = Luxor.get_fontsize()
        Luxor.fontsize(FONTSIZE * textscale)

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

function set_hue!(x::Blending, h)
    lightness = 0.5
    x.hue = (
        define_from(Luxor.RGB, h),
        define_from(Luxor.RGB, h; s=-lightness, v=lightness),
    )
    return x
end

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
    annotscale = 0.9,
    annotlead = 1.0,
    fun = Statistics.mean,
    kwargs...,
)
    # Define label text.
    v = get_value(collect_data(cascade))
    vlab = calculate(v, fun)
    vlab = round.(vlab; digits=abs(minimum(get_order.(vlab)))+1)
    lab = [@Printf.sprintf("%+2.2f",x) for x in vlab]
    N = size(v,1)

    # Remove sign from start, stop:
    [lab[ii] = string(lab[ii][2:end-1]) for ii in [1,N]]
    lab = vectorize(lab)

    # Define position
    wid = width(N)

    # Define x position.
    xmid = scale_x( ; steps=N)

    # Define y position.
    position = scale_for(cascade, Geometry; kwargs...)
    ymin = minimum.(position; dims=2) .- annotlead*annotscale*length.(lab) .- 0.5*SEP

    label = Labelbox.(lab, annotscale, Luxor.Point.(xmid,ymin), :center, annotlead)
    Geometry==Violin && (label = [label[1:end-1];missing])

    return label
end


"""
"""
function _define_from(::Type{Ticks}, Axis, cascade; x=0, y=HEIGHT, sep=0.5*SEP, kwargs...)
    p1 = _define_from(Vector{Luxor.Point}, Axis, cascade; x=x-sep, y=y-sep, kwargs...)
    p2 = _define_from(Vector{Luxor.Point}, Axis, cascade; x=x+sep, y=y+sep, kwargs...)
    lst = tuple.(p1,p2)

    return Ticks( ;
        shape = [Line(tup, _define_from(Coloring, "black"; alpha=1.0), :stroke) for tup in lst],
        arrow = _define_arrow(Axis; x=x, y=y, kwargs...),
    )
end


function _define_from(::Type{Vector{Luxor.Point}}, ::Type{YAxis}, cascade; x=0, shift=0, kwargs...)
    y = collect_ticks(cascade; kwargs...)
    y = scale_y(y; vlim(cascade; kwargs...)...) .+ shift
    return Luxor.Point.(x, y)
end


function _define_from(::Type{Vector{Luxor.Point}}, ::Type{XAxis}, cascade; y=HEIGHT, kwargs...)
    x = scale_x( ; steps=length(collect_data(cascade)))
    return Luxor.Point.(x, y)
end


function _define_from(::Type{Vector{Labelbox}}, ::Type{YAxis}, cascade::Cascade{Data};
    textscale=0.9,
    kwargs...,
)
    shift = -textscale*FONTSIZE*0.5
    lab = collect_ticks(cascade; kwargs...)
    pos = _define_from(Vector{Luxor.Point}, YAxis, cascade; x=-SEP, shift=shift, kwargs...)

    return _define_ticklabels(lab, pos; textscale=textscale, alignment=:right, kwargs...)
end


function _define_from(::Type{Vector{Labelbox}}, ::Type{XAxis}, cascade; y=HEIGHT, kwargs...)
    ticklabels = _define_from(Vector{Labelbox}, XAxis, cascade, get_label;
        y = y+SEP,
        leading = 0.0,
        kwargs...,
    )

    ticksublabels = _define_from(Vector{Labelbox}, XAxis, cascade, get_sublabel;
        y=y+SEP+FONTSIZE,
        textscale=0.8,
        kwargs...,
    )

    return ticklabels, ticksublabels
end


function _define_from(::Type{Vector{Labelbox}}, ::Type{XAxis}, cascade, fun::Function; y, kwargs...)
    lab = fun.(collect_data(cascade))
    pos = _define_from(Vector{Luxor.Point}, XAxis, cascade; y=y, kwargs...)
    return _define_ticklabels(lab, pos; alignment=:center, kwargs...)
end


"""
"""
function _define_ticklabels(lab::Vector, pos::Array{Luxor.Point};
    alignment,
    leading = 0.0,
    textscale = 0.9,
    kwargs...,
)
    N = length(lab)

    return if all(isempty.(lab))
        fill(missing,N)
    else
        wid = width(N; space=2)
        lab = [wrap_to(x, wid; textscale=textscale) for x in lab]
        Labelbox.(lab, textscale, pos, alignment, leading)
    end
end


"""
    _define_arrow()
This method defines an arrow from the origin to the end of the axis.
"""
_define_arrow(::Type{XAxis}; x=0, y=HEIGHT, kwargs...) = (Luxor.Point(x,y), Luxor.Point(WIDTH+2*SEP,y))
_define_arrow(::Type{YAxis}; x=0, y=HEIGHT, kwargs...) = (Luxor.Point(x,y), Luxor.Point(x,0))


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
    separator = "_",
    kwargs...,
)
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
    return lowercase(join(lst, maxchar>1 ? "-" : ""))
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
    titlescale=1.1,
    titleleading=1.1,
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

    return Labelbox(str, titlescale, Luxor.Point(WIDTH/2, -TOP_BORDER), :center, titleleading)
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