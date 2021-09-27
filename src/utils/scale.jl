"""
    scale_for
"""
function scale_for(cascade, ::Type{Violin}; kwargs...)
    v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
    v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
    
    vkde = calculate(v2, KernelDensity.kde)
    vlims = vlim(cascade; kwargs...)

    xl, xr = scale_x(vkde; kwargs...)
    y = scale_y(vkde; vlims...)
    
    # Ensure first point is also last point so the polygon will be closed.
    return vectorize(Luxor.Point.(
        hcat(xl, reverse(xr; dims=2)),
        hcat(y, reverse(y; dims=2))),
    )
end


function scale_for(cascade, ::Type{T}; kwargs...) where T<:Geometry
    v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
    v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
    
    vlims = vlim(cascade; kwargs...)

    y1 = scale_y(v1; vlims...)
    y2 = scale_y(v2; vlims...)

    x1, x2 = scale_x(cascade; kwargs...)

    pos = vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2))
    return all(length.(pos).==1) ? (pos = getindex.(pos,1)) : pos
    return pos
end


function scale_for(cascade, ::Type{T}, fun::Function, args...; kwargs...) where T<:Geometry
    vlims = vlim(cascade; kwargs...)
    return scale_for(calculate(copy(cascade), fun, args...), T; vlims...)
end


"""
    scale_x(data::Data, quantile::Real=1; kwargs...)
This function scales 
"""
function scale_x( ;
    nrow,
    shift::Float64=-0.5,
    ncol=1,
    subdivide=true,
    space=true,
    kwargs...,
)
    ROW, COL = nrow, (subdivide ? ncol : 1)
    extend = -sign(-0.5-shift) * (0.5*SEP * !space * !subdivide)
    
    wstep = width(nrow)
    wsample = wstep/COL

    Wstep = fill(wstep, (ROW,1))
    Wsample = fill(wsample, (1,COL))
    dWo = fill(SEP, (ROW,1))
    
    L = matrix(LinearAlgebra.UnitLowerTriangular, ROW; value=1)
    U = matrix(LinearAlgebra.UnitUpperTriangular, COL; value=1)

    dx = Wsample*(U+shift*I)
    x = (L-I)*Wstep + L*dWo .+ extend
    result = x .+ dx

    return subdivide ? result : hcat(fill(result, ncol)...)
end


function scale_x(lst::AbstractArray{T}; kwargs...) where T <: KernelDensity.UnivariateKDE
    v = matrix(getfield.(lst,:density))

    ROW, COL = size(v)
    xmid = scale_x( ; nrow=ROW, kwargs..., ncol=COL, subdivide=false)

    w = width(ROW)
    vmax = maximum(v; dims=2)
    factor = matrix(fill.(0.5 * w ./ vmax, COL))

    xl = xmid .- (factor .* v)
    xr = xmid .+ (factor .* v)
    return xl, xr
end


function scale_x(data::Vector{Data}; quantile=1.0, kwargs...)
    STEPS, SAMPLES = size(get_value(data))
    x1 = scale_x( ; nrow=STEPS, ncol=SAMPLES, shift=-(1-(1-quantile)/2), kwargs...)
    x2 = scale_x( ; nrow=STEPS, ncol=SAMPLES, shift=   -(1-quantile)/2,  kwargs...)
    return x1, x2
end


scale_x(cascade::T; kwargs...) where T <: Cascade = scale_x(collect_data(cascade); kwargs...)


"""
    scale_y(data::Data)
"""
function scale_y(v::AbstractArray; vmin, vmax, vscale, kwargs...)
    return -vscale * (max.(v,vmin) .- vmax)
end

function scale_y(lst::AbstractArray{T}; kwargs...) where T <: KernelDensity.UnivariateKDE
    return matrix(scale_y.(getfield.(lst,:x); kwargs...))
end

function scale_y(cascade::Cascade{Data}; kwargs...)
    vlims = vlim(cascade; kwargs...)
    return scale_y(collect_value(cascade); vlims..., kwargs...)
end


"""
    vlim(data::Vector{Data})
This function returns parameters that define value dimensions as they will be used to label
y-axis ticks.

# Returns
- `vmin::Float64`: (rounded) minimum data value
- `vmax::Float64`: (rounded) minimum data value
- `vscale::Float64`: scaling factor to convert value coordinates to drawing coordinates.
"""
function vlim(cascade; vmin=missing, vmax=missing, kwargs...)
    if |(ismissing(vmin), ismissing(vmax))
        tcks = collect_ticks(cascade; vmin=vmin, vmax=vmax, kwargs...)
        vmin = first(tcks)
        vmax = convert(Float64, last(tcks) + 0.5*tcks.step)
    end

    vscale = HEIGHT / (vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


"""
    collect_ticks(x::Cascade{Data}; kwargs...)
This function returns a list of major y-axis ticks
"""
function collect_ticks(cascade::Cascade{Data}; vmin=missing, vmax=missing, kwargs...)
    if |(ismissing(vmin), ismissing(vmax))
        major = _major_order(cascade)
        minor = _minor_order(cascade)
        
        vsum = cumulative_v(cascade; shift= 0.0, kwargs...)[1:end-1,:]
        # CUT IF NOT SUMMING FOR VIOLIN?
        # vkde = getfield.(calculate(v2, KernelDensity.kde),:x)
        # vsum = hcat(first.(vkde), last.(vkde))
        vsum = round.(vsum; digits=-minor)

        if ismissing(vmin)
            vmin = minimum(vsum)
            vmin!=0.0 && (vmin = floor(vmin-0.5*exp10(major); digits=-major))
        end

        if ismissing(vmax)
            vmax = maximum(vsum)
            vmax!=0.0 && (vmax = ceil(maximum(vsum) + 0.5*exp10(major); digits=-major))
        else
            vmax = floor(vmax; digits=major)
        end
    else
        major = _major_order([vmin,vmax])
        vmax = floor(vmax; digits=-major)
    end
    
    ticks = vmin:exp10(major):vmax
    length(ticks)<5 && (ticks = vmin:0.5*exp10(major):vmax)
    return ticks
end


"""
    scale_hsv(color; kwargs...)
This function decreases or increases `color` saturation by a factor of ``s \\in [-1,1]``.

# Keyword Arguments
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
    wrap_to(str, wid; scale)
This function wraps an input string `str` to the input `wid`, calculated assuming a
font size `scale` and returns an array of strings.
"""
function wrap_to(str::String, wid; scale)
    Luxor.@png begin
        tmp = Luxor.get_fontsize()
        Luxor.fontsize(FONTSIZE * scale)
        
        str = uppercase(str)
        lst = Luxor.textlines.(Luxor.textlines(str, wid), wid)

        idx = .!.&(isempty.(getindex.(lst,1)), length.(lst).==1)
        lst = lst[idx]

        idx = length.(lst).==2

        if any(idx)
            lst[idx] = Luxor.textlines.(_break(getindex.(lst[idx],2)), wid)
            lst = vcat(lst...)
            lst = Luxor.textlines(string(lst[.!isempty.(lst)] .* " "...), wid)
        else
            lst = vcat(lst...)
        end
        
        lst = vcat(lst...)
        Luxor.fontsize(tmp)
    end

    lst = lst[.!isempty.(lst)]
    return isempty(lst) ? Vector{String}() : lst
    # return lst[.!isempty.(lst)]
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