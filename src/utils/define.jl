import Base

"""
    define_from(::Type{Cascade{Data}}, df)
    define_from(::Type{Plot{Data}}, cascade; kwargs...)
    define_from(::Type{T}, cascade::Cascade{Data}; kwargs...) where T<:Axis

# Keyword Arguments
- `ylabel::String`, y-axis label
"""
function define_from(::Type{Cascade{Data}}, df::DataFrames.DataFrame;
    permutation = missing,
    correlate = true,
    permute = true,
    kwargs...,
)
    rows = size(df,1)
    maxstep = min(rows-2,length(COLORCYCLE))

    # Check for numbers in here lager than the colorcycle length?
    permutation = coalesce(permutation, collect(1:maxstep))
    
    idx = [1; sort(permutation).+1; rows]
    data = define_from(Vector{Data}, df[idx,:]; kwargs...)
    
    cascade = Cascade(
        start = first(data),
        stop = last(data),
        steps = data[2:end-1],
        correlation = random_rotation(length(permutation);
            nrandom=correlate,
            maxdim=maxstep,
            permutation=permutation,
            kwargs...,
        ),
        permutation = permutation,
        iscorrelated = false,
        ispermuted = false,
    )

    correlate!==false && correlate!(cascade)
    permute && (cascade = permute!(cascade))
    
    return cascade
end


function define_from(::Type{Data}, sdf::DataFrames.AbstractDataFrame;
    label,
    sublabel=missing,
    value=VALUE_COL,
    order=[],
    kwargs...,
)
    return Data( ; 
        label = sdf[1,label],
        sublabel = ismissing(sublabel) ? "" : sdf[1,sublabel],
        value = sdf[:,value],
        order = isempty(order) ? collect(1:size(sdf,1)) : order,
    )
end


function define_from(::Type{Vector{Data}}, df::DataFrames.DataFrame; kwargs...)
    gdf = fuzzify(df; kwargs...)
    data = [define_from(Data, sdf; kwargs...) for sdf in gdf]

    # Sort "start" samples by magnitude. Ensure consistent ordering in all subsequent steps.
    # iiorder = sortperm(get_value(data[1]))
    # [set_order!(data[ii], iiorder) for ii in 1:length(data)]

    return data
end


function define_from(::Type{Plot{T}}, cascade::Cascade{Data};
    rng = missing,
    legend = missing,
    nsample = missing,
    kwargs...,
) where T<:Geometry
    vlims = vlim(cascade; kwargs...)

    nsample = coalesce(nsample, length(cascade))
    !ismissing(rng) && getindex!(cascade, rng)
    trend = get_trend(cascade)

    cascade_geometry = set_geometry(cascade, T; nsample=nsample, vlims..., kwargs...)
    legd = _define_legend(cascade_geometry; nsample=nsample, trend=trend, vlims..., kwargs...)
    
    return Plot( ;
        cascade = cascade_geometry,
        xaxis = define_from(XAxis, cascade; nsample=nsample, vlims..., kwargs...),
        yaxis = define_from(YAxis, cascade; nsample=nsample, vlims..., kwargs...),
        title = _define_title(cascade; nsample=nsample, rng=rng, vlims..., kwargs...),
        path = _define_path(cascade, T; nsample=nsample, rng=rng, vlims..., kwargs...),
        # Add other annotations to the legend.
        legend = _push!(legd, cascade, T, legend; trend=trend, nsample=nsample, vlims..., kwargs...),
    )
end


function define_from(::Type{XAxis}, cascade::Cascade{Data}; kwargs...)
    T = Vector{Label{Vector{String}}}
    pad = SEP/2
    
    ticklabels = _define_from(T, cascade, XAxis, :label;
        yshift = pad,
        scale = 0.85,
        kwargs...,
    )
    ticksublabels = _define_from(T, cascade, XAxis, :sublabel;
        yshift = height(ticklabels)+SEP,
        scale = 0.9,
        # currency = true,
        kwargs...,
    )
    frame = _define_from(Line, Luxor.Point.((0,WIDTH+SEP), HEIGHT))

    return XAxis(ticklabels, ticksublabels, frame)
end


function define_from(::Type{YAxis}, cascade::Cascade{Data};
    ylabel,
    x = 0,
    y = HEIGHT,
    kwargs...,
)
    T = Label{String}

    ticks = _define_ticks(cascade, YAxis; kwargs...)
    ticklabels = _define_from(Vector{T}, cascade, YAxis;
        halign = :right,
        xshift = -SEP,
        scale = 0.9,
        kwargs...,
    )
    label = _define_from(T, ylabel, Luxor.Point(-width(ticklabels)-2*SEP, HEIGHT/2);
        angle = -pi/2,
        valign = :bottom,
    )
    frame = _define_from(Arrow, Luxor.Point.(0, (HEIGHT,0)))
    
    return YAxis(label, ticks, ticklabels, frame)
end


function define_from(::Type{T}, x; kwargs...) where T <: Luxor.Colorant
    return scale_hsv(parse(T, _define_colorant(x)); kwargs...)
end


"""
    _define_from(Shape, Color, pos, sgn; kwargs...)
    _define_from(::Type{T}, sign, pos; kwargs...) where T<:Vector{Blending}
    _define_from(::Type{T}, sign; kwargs...) where T<:Union{Vector{Coloring},Coloring}

# Keyword Arguments:
- `style`


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


    _define_from(Handle, cascade, fun, args...)


    _define_from(Annotation)
"""
function _define_from(Shape, Color, pos::Vector{T1}, sgn::Vector{T2};
    kwargs...,
) where {T1<:AbstractArray, T2<:AbstractArray}
    return _define_from.(Shape, Color, pos, sgn; kwargs...)
end

function _define_from(Shape, Color, pos::Vector{T}, sgn;
    style,
    kwargs...,
) where T <: Luxor.Point
    return Shape(pos, _define_from(Color, sgn, pos; kwargs...), style)
end

function _define_from(Shape, Color, pos::Vector{T}, sgn;
    style,
    kwargs...,
) where T <: Tuple
    return Shape.(pos, _define_from(Vector{Color}, sgn, pos; kwargs...), style)
end


function _define_from(::Type{Coloring}, sign, args...;
    alpha = 0.66,
    kwargs...,
)
    hue = define_from(Luxor.RGB, sign; kwargs...)
    alpha = _define_alpha(alpha; kwargs...)
    return Coloring(hue, alpha)
end


function _define_from(::Type{Vector{Coloring}}, args...; kwargs...)
    return _define_from.(Coloring, args...; kwargs...)
end


function _define_from(::Type{Vector{Blending}}, sgn, pos; kwargs...)
    hue = _define_gradient.(sgn)
    
    # Calculate direction.
    xmid = mid(pos; dims=1)
    
    ii = Dict(k => sgn.==k for k in [-1,1])
    ymax = Dict(k => maximum(pos[v]; dims=2) for (k,v) in ii)
    ymin = Dict(k => minimum(pos[v]; dims=2) for (k,v) in ii)

    begin y1 = fill(0.0, size(sgn)); y2 = fill(0.0, size(sgn)) end
    begin y1[ii[-1]] .= ymin[-1]; y2[ii[-1]] .= ymax[-1] end
    begin y1[ii[+1]] .= ymax[+1]; y2[ii[+1]] .= ymin[+1] end

    direction = tuple.(Luxor.Point.(xmid,y1), Luxor.Point.(xmid,y2))
    return Blending.(direction, hue)
end


## Define Label; lists of Labels

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
        text = uppercase.(text),
        scale = scale,
        position = pos,
        halign = halign,
        valign = valign,
        angle = angle,
        leading = leading,
    )
end

function _define_from(::Type{T}, x::Float64, args...; kwargs...) where T<:Label
    txt = @Printf.sprintf("%.2g", x)
    return _define_from(T, txt, args...; kwargs...)
end

function _define_from(::Type{T}, txt::String, pos::Luxor.Point, wid::Float64;
    scale = 1,
    kwargs...,
) where T <: Label
    return _define_from(T, wrap_to(txt, wid; scale), pos; scale=scale, kwargs...)
end


function _define_from(::Type{Vector{Label{T}}}, txt::AbstractArray, pos::AbstractArray;
    kwargs...,
) where T <: Vector{String}
    N = length(pos)
    wid = width(N; space=2)
    return [_define_from(Label, txt[ii], pos[ii], wid; kwargs...) for ii in 1:N]
end


function _define_from(::Type{Vector{Label{T}}}, text::AbstractArray, pos::AbstractArray;
    kwargs...,
) where T <: Any
    return [_define_from(Label{T}, text[ii], pos[ii]; kwargs...) for ii in 1:length(pos)]
end


function _define_from(::Type{T}, x; kwargs...) where T<:Label
    return _define_from(T, x, Luxor.Point(0,0); kwargs...)
end


## Define Arrow, Line (for plot axes)

function _define_from(::Type{T}, x::Tuple{Luxor.Point,Luxor.Point};
    hue = "black",
    alpha = 1.0,
    style = :stroke,
    kwargs...,
) where T <: Union{Arrow,Line}
    return T(x, _define_from(Coloring, hue; alpha=alpha), style)
end


## Define Handle

function _define_from(::Type{Handle}, cascade::Cascade{Violin};
    scale = 0.8,
    colorcycle,
    kwargs...,
)
    N = length(cascade)
    # if colorcycle
        str = "SAMPLE" * (N>1 ? "S" : "")
        shape = Box( ; 
            position = Luxor.Point.((0,1),0),
            color = Coloring(_define_colorant("black"), cascade.start.shape.color.alpha),
            style = :fill,
        )
        label = _define_from(Label, uppercase(str); halign=:left, scale=scale)
    # end
    return [set_position!(Handle(shape, label); scale=scale, kwargs...)]
end


function _define_from(::Type{Handle}, cascade::Cascade{T}, str::String;
    scale = 0.8,
    kwargs...,
) where T <: Geometry
    shape = get_shape(cascade)
    label = _define_from(Label, uppercase(str); halign=:left, scale=scale)
    return set_position!(Handle(shape, label); scale=scale, kwargs...)
end


function _define_from(::Type{Handle}, cascade, fun::Function, args...; kwargs...)
    return _define_from(Handle, cascade, _title_function(fun, args...); kwargs...)
end


function _define_from(::Type{Handle}, cascade, str::String, hue; kwargs...)
    h = _define_from(Handle, cascade, str; kwargs...)
    return set_hue!(h, hue)
end


function _define_from(::Type{Handle}, cascade; colorcycle, kwargs...)
    #= !!!!
    Should probably set a lower limit on alpha for large numbers of samples.
    This gets really light and hard to see.
    =# 
    return if colorcycle
        [_define_from(Handle, cascade, "SAMPLE", "black"; idx=1, kwargs...)]
    else
        [_define_from(Handle, cascade, str, hue; idx=idx, colorcycle=colorcycle, kwargs...)
            for (idx, str, hue) in zip(1:2, ["GAIN","LOSS"], [HEX_GAIN,HEX_LOSS])]
    end
end


## Define Annotation

function _define_from(::Type{Annotation}, cascade::Cascade{Data}, T::DataType,
    args...;
    scale = 0.9,
    kwargs...,
)
    # !!!! Maybe better way to align violin plot position?
    # valign = T==Violin ? :top : :bottom
    valign = :bottom

    cascade_args = update_stop!(copy(calculate(cascade, args...)))
    label = _define_label(cascade, T, args...; scale=scale, valign=valign, kwargs...)
    cascade = set_geometry(cascade_args, Horizontal, args...; alpha=1.0, style=:stroke, kwargs...)

    T==Violin && _shift_position!(label, cascade)

    return Annotation(cascade, label)
end


function _shift_position!(label, cascade)
    data = collect_data(cascade)
    pts = collect.(getfield.(getindex.(getfield.(data,:shape),1),:position))
    y = minimum.(pts; dims=2)

    [label[ii].position = Luxor.Point(label[ii].position[1], y[ii]-SEP) for ii in 1:length(label)]
    return label
end


## Define values for DataTypes PROPERTIES

"""
    _define_alpha(N::Int; kwargs...)
This function calculates an alpha for `N` samples to scale transparency for overlays:

```math
\\alpha = \\min\\left\\lbrace\\dfrac{w}{f(N)},\\, 0\\right\\rbrace
```

# Keyword Arguments
- `factor::Real=0.25`, scaling weighting ``w``
- `fun::Function=log`, scaling function ``\\ln``
"""
function _define_alpha(N::Int; factor::Real=0.25, fun::Function=log, kwargs...)
    return min(factor/fun(N), 1.0)
end

_define_alpha(x; kwargs...) = x


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

function _define_gradient(x1, x2; kwargs...)
    return tuple(define_from(Luxor.RGB, x1; kwargs...), define_from(Luxor.RGB, x2; kwargs...))
end


"""
    _define_label(cascade, Geometry::DataType, args...; kwargs...)
"""
function _define_label(cascade::Cascade{Data}, Geometry::DataType, args...; kwargs...)
    txt = _define_text(cascade, args...; kwargs...)
    pos = _define_position(cascade, Geometry; kwargs...)
    return _define_from(Vector{Label{String}}, txt, pos; valign=:bottom, kwargs...)
end


"""
    _define_legend(cascade; kwargs)
"""
function _define_legend(cascade::Cascade{T}; kwargs...) where T <: Geometry
    legend = _define_from(Handle, cascade; kwargs...) .=> missing
    return legend |> Vector{Pair{Handle,Any}}
end


"""
    _push!(legend, cascade, Geometry, args...; kwargs...)

# Arguments
- `legend`
- `cascade::Cascade{Data}`
- `fun::Function`
"""
function _push!(
    legend::Vector{Pair{Handle,T}},
    cascade::Cascade{Data},
    Geometry::DataType,
    fun::Function,
    args...;
    kwargs...,
) where T<:Any
    a = _define_from(Annotation, cascade, Geometry, fun, args...; kwargs...)
    h = _define_from(Handle, a.cascade, fun, args...;
        idx=length(legend)+1,
        kwargs...,
    )
    push!(legend, h => a)
    return legend
end

function _push!(legend, cascade, Geometry, args::Tuple; kwargs...)
    return _push!(legend, cascade, Geometry, args...; kwargs...)
end

function _push!(legend, cascade, Geometry, lst::Vector; kwargs...)
    [_push!(legend, cascade, Geometry, args...; kwargs...) for args in lst]
    return legend
end

_push!(legend, cascade, Geometry, args::Missing; kwargs...) = legend


"""
    _define_path(cascade::Cascade, Geometry; kwargs...)
This method defines the path to which to write the file:
    Geometry/Geometry_n<nsample>_colorcycle<0/1>_corr<0/1>_<permutation>.png
"""
function _define_path(cascade::Cascade, T::DataType;
    colorcycle::Bool,
    dir=WATERFALL_DIR,
    subdir="",
    figdir="fig",
    ext=".png",
    kwargs...,
)
    subdir = lowercase(replace(subdir, r" "=>"-"))

    file = unique(lowercase.([
        subdir,
        string(T),
        _define_path(string.(cascade.permutation)),
        "colorcycle" * _define_path(colorcycle),
        _path_sample(cascade; kwargs...),
    ]))
    file = file[.!isempty.(file)]
    
    path = joinpath(dir, figdir, file[1])
    if !isdir(path)
        @info("Creating directory: $path")
        mkpath(path)
    end

    return joinpath(path, join(file,"_")) * ext
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
"""
_path_sample(nsample::Int, rng::Missing; kwargs...) = _path_sample(nsample; kwargs...)

function _path_sample(nsample::Int, rng::AbstractArray{Int}; kwargs...)
    return join([
        _path_sample(nsample; kwargs...),
        lpad(rng[end], length(string(nsample)), "0"),
    ], "-")
end

function _path_sample(nsample::Int; maxsample=50, kwargs...)
    return "n" * _define_path(nsample; maxchar=get_order(maxsample)+1)
end

function _path_sample(x::Cascade; nsample=missing, rng=missing, kwargs...)
    nsample = coalesce(nsample, length(x))
    return _path_sample(nsample, rng; kwargs...)
end


"""
    _define_position(cascade, ::Type{T}; kwargs...) where T <: Axis
This method defines the TICK POSITIONS for the input Axis subtype (XAxis or YAxis)
`XAxis` tick labels are centered below the associated cascade waterfall.

    _define_position(cascade, Geometry::DataType; kwargs...)
This method defines a point above the top of each cascade waterfall, so that an annotation
label can be bottom/center-aligned at these points.

# Arguments
- `cascade`
- ``

# Keyword Arguments
- `x=0`, x-coordinate of y-axis.
- `y=HEIGHT`, y-coordinate of x-axis.
- `xshift`
- `yshift`
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
    x = scale_x( ; nrow=length(collect_data(cascade)))
    return Luxor.Point.(x, y+yshift)
end


function _define_position(cascade, Geometry; kwargs...)
    yshift = -SEP/2
    x = scale_x( ; nrow=length(collect_data(cascade)))
    pos = vectorize.(scale_for(cascade, Geometry; kwargs...))
    y = minimum.(pos; dims=2)
    return Luxor.Point.(x, y.+yshift)
end


"""
    _define_text(x::Float64; kwargs...)
This method formats `x` as a string.

# Keyword Arguments
- `digits=2`, fractional digits to include
- `sgn=true`, indicates whether to show a leading `+`

    _define_text(cascade, fun::Function, args...; kwargs...)
This method calculates a value 
"""
function _define_text(x::Float64; sgn=true, digits=2, currency=false, kwargs...)
    x = round(x; digits=digits)
    sgn = sgn ? sgn : Base.sign(x)<0
    
    if currency
        str = _define_currency(x; major=digits)
    else
        len = length(string(abs(convert(Int, round(x))))) + 1 + sgn
        str = sgn ? @Printf.sprintf("%+2.10f", x) : @Printf.sprintf("%2.10f", x)
    end

    return string(str[1:len+digits])
end


function _define_text(cascade, fun::Function, args...; kwargs...)
    v = collect_value(cascade)
    v = update_stop!(calculate(v, fun, args...))

    digits = -_minor_order(cascade)
    digits==0 && (digits=1)

    str = _define_text.(v; digits=digits, kwargs...)
    [str[ii] = str[ii][2:end] for ii in [1,size(str,1)]]
    
    iszero = .!isnothing.(match.(r"[+-]0[.]0+$", str))
    str[iszero] .= replace.(str[iszero], r"[+-]"=>"+/-")

    return str
end


function _define_text(cascade, ::Type{YAxis}; scale=0.9, kwargs...)
    v = collect_ticks(cascade; kwargs...)
    # Take digits from the order of the tick step in case we added half steps.
    digits = -get_order(convert(Float64, v.step))
    digits==0 && (digits=1)
    return _define_text.(v; digits=digits, sgn=false)
end


function _define_text(cascade, ::Type{XAxis}, field::Symbol; kwargs...)
    txt = getfield.(collect_data(cascade), field)
    return _define_currency(txt)
end


# _define_text(x) = x


"""
"""
function _define_currency(lst::Vector{Float64}; kwargs...)
    minor = _minor_order(lst)
    # str = _define_currency.(lst; minor=minor)
    str = _define_currency.(lst)
    [str[ii] = "+" * str[ii] for ii in 2:length(str)-1]
    return str
end


function _define_currency(x::Float64; minor=missing)
    str = if x==0.0
        " –"
    else
        order = get_order(x)
        rpad(string(x)[1], mod(order,3)+1, "0") * _get_suffix(order)
        # sffx = _get_suffix(order)


        # minor = coalesce(minor, get_order(x))
        # dgts = get_order(x)-minor
        # # dgts==0 && (dgts=1)

        # str = Printf.@sprintf("%.10e", round(x; digits=-minor))
        # replace(str,
        #     match(Regex("\\d[.]0{$dgts}(.*)"), str)[1] => _get_suffix(minor),
        # )
    end
    return str * " USD"
end

_define_currency(x; kwargs...) = x


"""
"""
function _get_suffix(x::Int)
    d = Dict(3=>"k", 6=>"M", 9=>"b", 12=>"T")
    d = Dict(k:k+2 => v for (k,v) in d)
    k = collect(keys(d))
    ii = in.(x,k)
    return any(ii) ? d[k[ii][1]] : ""
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
    _define_title(cascade::Cascade{Data}; kwargs...)
This method formats a title to describe, where applicable:
1. The number of samples,
2. Range of correlation coefficients (if a correlation was applied), and
3. The distribution function (normal or uniform) used to create samples
    (if more than one sample).
"""
function _define_title(str::Vector{String};
    titlescale = 1.1,
    titleleading = 1.2,
    kwargs...,
)
    lab = _define_from(Label{Vector{String}}, str;
        scale=titlescale,
        leading=titleleading,
    )

    lab.position = Luxor.Point(WIDTH/2, -height(lab))

    return lab
end


function _define_title(cascade::Cascade{Data}; kwargs...)
    # Select which rows of the title to show:
    # (1) Always show the number of samples,
    # (2) Show correlation range if one is applied,
    # (3) Show sample distribution if multiple samples are given.
    str = [
        _title_correlation( ; kwargs...),
        _title_distribution( ; kwargs...),
        _title_sample( ; kwargs...),
    ]

    str = String.(str[.!isempty.(str)])

    return _define_title(str; kwargs...)
end


function _define_title(
    str::String;
    ylabel,
    metric,
    kwargs...,
)
    return _define_title(uppercase.([
        str,
        "$ylabel per investment",
        "Goal: Maximize $metric",
        _title_sample( ; kwargs...),
    ]))
end


""
function _title_function(fun::Function, args...)
    return if fun==Statistics.quantile
        _title_quantile(args...)
    else
        string(fun)
    end
end


function _title_quantile(p::Float64)
    if p==0.5
        return "median"
    else
        str = Printf.@sprintf("%.d", p*100)
        return if str[end]=='1';  str * "st %ile"
        elseif str[end]=='2';     str * "nd %ile"
        elseif str[end]=='3';     str * "rd %ile"
        else;                     str * "th %ile"
        end
    end
end


"Format title string for normal distribution function"
_title_normal(x) = "N(x; t),  t~U($(x[1]), $(x[2]))"


"Format title string for uniform distribution function"
function _title_uniform(x; abs::Bool=false)
    return "U($(x[1]), $(x[2]))"
end


"Format title string for SAMPLE distribution"
function _title_distribution( ; distribution=missing, fuzziness=missing, nsample, kwargs...)
    |(ismissing(distribution), ismissing(fuzziness), nsample==1) && return " "
    
    str = "DISTRIBUTION:  "

    return if distribution==:normal;       str * _title_normal(fuzziness)
    elseif distribution==:uniform;  str * _title_uniform(fuzziness)
    else; ""
    end
end


"Format title string for correlation coefficient"
function _title_correlation( ; interactivity=missing, kwargs...)
    return if ismissing(interactivity); " "
    else
        "CORRELATION:  |R| ~ " * _title_uniform(interactivity; abs=true)
    end
end


"Format string to print number of samples for a plot title."
function _title_sample( ; nsample, rng=missing, kwargs...)
    nsample==1 && return " "
    return string(
        ismissing(rng) ? "" : lpad(rng[end], length(string(nsample)), " ")*"/",
        nsample,
        " SAMPLE",
        (nsample==1 ? "" : "S"),
    )
end