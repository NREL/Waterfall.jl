"""
    set_geometry(cascade, ::Type{T}; kwargs...) where T<:Geometry
Given a cascade and geometry, return a cascade with an updated type.
"""
function set_geometry(cascade, ::Type{Violin}, args...; kwargs...)
    return _set_geometry(cascade, Violin, Poly, Coloring, args...; style=:fill, kwargs...)
end


function set_geometry(cascade, ::Type{Vertical}, args...; kwargs...)
    return _set_geometry(cascade, Vertical, Box, Blending, args...;
        style=:fill,
        subdivide=true,
        space=true, 
        kwargs...,
    )
end


function set_geometry(cascade, ::Type{Horizontal}, args...; usegradient=missing, kwargs...)
    usegradient = coalesce(usegradient, length(cascade)==1)
    
    return _set_geometry(cascade, Horizontal, Box, usegradient ? Blending : Coloring, args...;
        alpha=length(cascade),
        style=:fill,
        subdivide=false,
        space=true,
        kwargs...,
    )
end


function set_geometry(cascade, ::Type{Parallel}, args...; slope::Bool=true, kwargs...)
    return _set_geometry(cascade, Parallel, Line, Coloring, args...;
        quantile = convert(Float64, slope),
        alpha = length(cascade),
        factor = 0.5,
        style = :stroke,
        subdivide = false,
        space = false,
        kwargs...,
    )
end


"""
    _set_geometry(cascade::Cascade{Data}, Geometry, Shape, Color; kwargs...)
"""
function _set_geometry(cascade::Cascade{Data}, Geometry, Shape, Color, args...;
    colorcycle::Bool = false,
    kwargs...,
)
    pos = scale_for(cascade, Geometry, args...; kwargs...)
    sgn = sign(cascade)

    label = get_label.(collect_data(cascade))
    shape = vectorize.(_define_from(Shape, Color, pos, sgn; kwargs...))

    data = Geometry.(label, shape, length(cascade))
    
    return Cascade(
        start = set_hue!(first(data), "black"),
        stop = set_hue!(last(data), "black"),
        steps = colorcycle ? set_hue!.(data[2:end-1], cascade.permutation) : data[2:end-1],
        permutation = cascade.permutation,
        correlation = cascade.correlation,
        ispermuted = cascade.ispermuted,
        iscorrelated = cascade.iscorrelated,
    )
end


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