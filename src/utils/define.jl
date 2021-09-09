import Base


"""
    define_from(::Type{Cascade{Data}}, df)
    define_from(::Type{Plot{Data}}, cascade; kwargs...)
    define_from(::Type{T}, cascade::Cascade{Data}; kwargs...) where T<:Axis

# Keywords
- `ylabel::String`, y-axis label
- 
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


function define_from(::Type{Data}, sdf::DataFrames.SubDataFrame;
    label,
    sublabel,
    value=VALUE_COL,
    order=[],
    kwargs...,
)
    return Data( ; 
        label = sdf[1,label],
        sublabel = sdf[1,sublabel],
        value = sdf[:,value],
        order = isempty(order) ? collect(1:size(sdf,1)) : order,
    )
end


function define_from(::Type{Vector{Data}}, df::DataFrames.DataFrame; kwargs...)
    gdf = fuzzify(df; kwargs...)
    data = [define_from(Data, sdf; kwargs...) for sdf in gdf]
    
    # Sort "start" samples by magnitude. Ensure consistent ordering in all subsequent steps.
    iiorder = sortperm(get_value(data[1]))
    [set_order!(data[ii], iiorder) for ii in 1:length(data)]

    return data
end


function define_from(::Type{Plot{Data}}, cascade::Cascade{Data}; kwargs...)
    axes = [
        define_from(XAxis, cascade; kwargs...);
        define_from(YAxis, cascade; kwargs...);
    ]
    
    return Plot(cascade, axes, _define_title(cascade; kwargs...), "")
end


function define_from(::Type{Plot{T}}, cascade::Cascade{Data}; kwargs...) where T<:Geometry
    plot = define_from(Plot{Data}, copy(cascade); kwargs...)
    return set_geometry(plot, T; kwargs...)
end


function define_from(::Type{XAxis}, cascade::Cascade{Data}; kwargs...)
    label_type = Vector{Label{Vector{String}}}
    pad = SEP/2
    
    return XAxis( ;
        # ticks = _define_from(Ticks, cascade, XAxis; kwargs...),
        ticklabels = _define_from(label_type, cascade, XAxis, :label;
            yshift = pad,    
            kwargs...,
        ),
        ticksublabels = _define_from(label_type, cascade, XAxis, :sublabel;
            yshift = pad+FONTSIZE,
            scale = 0.8,
            kwargs...,
        ),
        frame = _define_from(Line, (Luxor.Point(0,HEIGHT), Luxor.Point(WIDTH+2*SEP,HEIGHT)))
    )
end


function define_from(::Type{YAxis}, cascade::Cascade{Data};
    ylabel,
    x = 0,
    y = HEIGHT,
    kwargs...,
)
    label_type = Label{String}

    return YAxis( ;
        ticks = _define_ticks(cascade, YAxis; kwargs...),
        label = _define_from(label_type, ylabel, Luxor.Point(-(LEFT_BORDER-SEP/2), HEIGHT/2);
            angle = -pi/2,
            valign = :top,
        ),
        ticklabels = _define_from(Vector{label_type}, cascade, YAxis;
            halign = :right,
            xshift = -SEP,
            scale = 0.9,
            kwargs...,
        ),
        frame = _define_from(Arrow, (Luxor.Point(0,HEIGHT), Luxor.Point(0,0))),
    )
end


function define_from(::Type{T}, x; kwargs...) where T <: Luxor.Colorant
    return scale_hsv(parse(T, _define_colorant(x)); kwargs...)
end


"""
    _define_from(Shape, Color, pos, sgn; kwargs...)
    _define_from(::Type{T}, sign, pos; kwargs...) where T<:Vector{Blending}
    _define_from(::Type{T}, sign; kwargs...) where T<:Union{Vector{Coloring},Coloring}

# Keywords:
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
    alpha = 0.8,
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


function _define_from(::Type{T}, x; kwargs...) where T<:Label
    return _define_from(Label, x, Luxor.Point(0,0))
end


## Define Handle

function _define_from(::Type{Handle}, cascade::Cascade{T}, str::String;
    scale = 0.8,
    kwargs...,
) where T <: Geometry
    shape = get_shape(cascade)
    label = _define_from(Label, str; halign=:left, scale=scale)
    return set_position!(Handle(shape, label); scale=scale, kwargs...)
end


function _define_from(::Type{Handle}, cascade, fun::Function, args...; kwargs...)
    return _define_from(Handle, cascade, string(fun); kwargs...)
end


function _define_from(::Type{Handle}, cascade, str::String, hue; kwargs...)
    h = _define_from(Handle, cascade, str; kwargs...)
    return set_hue!(h, hue)
end


function _define_from(::Type{Handle}, cascade; colorcycle, kwargs...)
    return [_define_from(Handle, cascade, str, hue; idx=idx, kwargs...)
        for (idx, str, hue) in zip(1:2, ["GAIN","LOSS"], [HEX_GAIN,HEX_LOSS])]
end


## Define Annotation

function _define_from(::Type{Annotation}, cascade::Cascade{Data}, Geometry::DataType,
    args...;
    scale = 0.8,
    kwargs...,
)
    return Annotation(
        label = _define_label(cascade, Geometry, args...; scale=scale, kwargs...),
        cascade = set_geometry(cascade, Geometry, args...; alpha=1.0, style=:stroke, kwargs...),
    )
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
    args...;
    kwargs...,
) where T<:Any
    a =  _define_from(Annotation, cascade, Geometry, args...; kwargs...)
    h = _define_from(Handle, a.cascade, args...; idx=length(legend)+1, kwargs...)
    push!(legend, h => a)
    return legend
end


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
    _set_geometry(plot::Plot{Data}, Geometry, Shape, Color; kwargs...)
"""
function _set_geometry(cascade::Cascade{Data}, Geometry, Shape, Color, args...;
    colorcycle::Bool = false,
    kwargs...,
)
    pos = scale_for(cascade, Geometry, args...; kwargs...)
    sgn = sign(cascade)

    label = get_label.(collect_data(cascade))
    shape = vectorize.(_define_from(Shape, Color, pos, sgn; kwargs...))
    # annot = _define_annotation(cascade, Missing; kwargs...)

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


function _set_geometry(plot::Plot{Data}, Geometry::DataType, args...; kwargs...)
    cascade = _set_geometry(plot.cascade, Geometry, args...; kwargs...)
    path = _define_path(plot.cascade, Geometry; kwargs...)
    return Plot(cascade, plot.axes, plot.title, path)
end