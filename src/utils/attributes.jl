"""
    set_position!(handle::Handle)
This method calculates the position of a Handle's shape and label such that the shape is
centered at (x0,y0) and fits within the bounds of `(2*dx, 2*dy)`. The label is aligned
middle/left at `(x0+dx+space, y0)`
"""
function set_position!(handle::Handle;
    x0 = WIDTH-100,
    y0 = 3*SEP,
    dx = 2*SEP,
    dy = SEP,
    space = SEP,
    idx = 1,
    kwargs...,
)
    y0 = y0 + (2*dy+space)*(idx-1)
    
    setproperty!(handle.shape, :position, (
        Luxor.Point(x0-dx, y0+dy),
        Luxor.Point(x0+dx, y0-dy),
    ))
    
    setproperty!(handle.label, :position, Luxor.Point(x0+dx+space, y0))

    return handle
end


"""
    get_shape(cascade; kwargs...)
This function returns the shape used in `cascade`, with its position updated, as defined by
keyword arguments.
"""
get_shape(cascade::Cascade{T}) where T<:Geometry = copy(first(cascade.start.shape))


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

set_hue!(x::Handle, h; kwargs...) = begin set_hue!(x.shape, h; kwargs...); return x end
set_hue!(x::Blending, h) = begin x.hue = _define_gradient(h); return x end
set_hue!(x::T, h) where T<:Geometry = begin set_hue!(x.shape, h); return x end
set_hue!(x::T, h) where T<:Shape = begin set_hue!(x.color, h); return x end
set_hue!(x::Vector{T}, h) where T<:Shape = begin set_hue!.(x, h); return x end


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



"""
"""
