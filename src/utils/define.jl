import Base

"""
This function returns position
"""
function _calculate_position(cascade, ::Type{Violin},  args...; kwargs...)
    return scale_kde(cascade)
end

function _calculate_position(cascade, ::Type{T}; kwargs...) where T<:Geometry
    return scale_point(cascade; kwargs...)
end


"""
    define_from(::Type{Cascade{Data}}, df)
    define_from(::Type{Plot{Data}}, cascade)
    define_from(::Type{T}, cascade::Cascade{Data}; kwargs...) where T<:Axis
"""
function define_from(::Type{Cascade{Data}}, df::DataFrames.DataFrame;
    ncor=DEFAULT_NCOR,
    maxdim=length(COLORCYCLE),
    permutation=1:length(COLORCYCLE),
    correlate=true,
    permute=true,
    kwargs...,
)
    # maxdim = min(maxdim, size(df,1)-2)
    maxdim = size(df,1)
    permutation = collect(permutation)

    idx = [1;sort(permutation).+1;maxdim]
    data = define_from(Vector{Data}, df[idx,:]; kwargs...)
    
    cascade = Cascade(
        start = first(data),
        stop = last(data),
        steps = data[2:end-1],
        correlation = random_rotation(length(permutation), ncor; maxdim=maxdim, permutation=permutation, kwargs...),
        permutation = permutation,
        iscorrelated = false,
        ispermuted = false,
    )

    correlate && correlate!(cascade)
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
    
    return Plot(cascade, axes)
end


function define_from(::Type{Plot{T}}, cascade::Cascade{Data}; kwargs...) where T<:Geometry
    plot = define_from(Plot{Data}, copy(cascade); kwargs...)
    return set_geometry(plot, T; kwargs...)
end


function define_from(::Type{XAxis}, cascade::Cascade{Data}; xlabel="", kwargs...)
    data = collect_data(cascade)
    # perm = collect_permutation(cascade)
    # cascade::Cascade{Data}

    N = length(data)
    xticklabels = get_label.(data)
    xticksublabels = get_sublabel.(data)
    xticks = cumulative_x( ; steps=N)
    return XAxis( ; label=xlabel, ticklabels=xticklabels, ticksublabels=xticksublabels, ticks=xticks, lim=(1,N))
end

function define_from(::Type{YAxis}, cascade::Cascade{Data}; ylabel, kwargs...)
    data = collect_data(cascade)
    vlims = vlim(data)
    vmin, vmax, vscale = vlims
    yticklabels = collect(vmin:floor(vmax))
    yticks = scale_y(yticklabels; vlims...)
    return YAxis( ; label=ylabel, ticklabels=yticklabels, ticks=yticks, lim=(vmin,vmax))
end


"""
    _define_from(Shape, Color, position, sgn; kwargs...)
    _define_from(::Type{T}, sign, position; kwargs...) where T<:Vector{Blending}
    _define_from(::Type{T}, sign; kwargs...) where T<:Union{Vector{Coloring},Coloring}

# Keywords:
- `style`
"""
function _define_from(Shape, Color, position::Vector{T1}, sgn::Vector{T2};
    kwargs...,
) where {T1<:AbstractArray, T2<:AbstractArray}
    return _define_from.(Shape, Color, position, sgn; kwargs...)
end

function _define_from(Shape, Color, position::Vector{T}, sgn;
    style, kwargs...) where T <: Luxor.Point
    return Shape(position, _define_from(Color, sgn, position; kwargs...), style)
end

function _define_from(Shape, Color, position::Vector{T}, sgn;
    style, kwargs...) where T <: Tuple
    return Shape.(position, _define_from(Vector{Color}, sgn, position; kwargs...), style)
end


function _define_from(::Type{Coloring}, sign, args...; alpha=0.8, kwargs...)
    hue = define_from(Luxor.RGB, sign; kwargs...)
    alpha = _define_alpha(alpha; kwargs...)
    return Coloring(hue, alpha)
end

function _define_from(::Type{Vector{Coloring}}, args...; kwargs...)
    return _define_from.(Coloring, args...; kwargs...)
end


function _define_from(::Type{Vector{Blending}}, sgn, position; kwargs...)
    lightness = 0.5
    h1 = define_from.(Luxor.RGB, sgn)
    h2 = define_from.(Luxor.RGB, sgn; s=-lightness, v=lightness)
    hue = tuple.(h1, h2)

    # Calculate direction.
    xmid = mid(position; dims=1)

    ii = Dict(k => sgn.==k for k in [-1,1])
    ymax = Dict(k => maximum(position[v]; dims=2) for (k,v) in ii)
    ymin = Dict(k => minimum(position[v]; dims=2) for (k,v) in ii)

    begin y1 = fill(0.0, size(sgn)); y2 = fill(0.0, size(sgn)) end
    begin y1[ii[-1]] .= ymin[-1]; y2[ii[-1]] .= ymax[-1] end
    begin y1[ii[+1]] .= ymax[+1]; y2[ii[+1]] .= ymin[+1] end

    direction = tuple.(Luxor.Point.(xmid,y1), Luxor.Point.(xmid,y2))
    return Blending.(direction, hue)
end


"""
    set_geometry(cascade, ::Type{T}; kwargs...) where T<:Geometry
Given a cascade and geometry, return a cascade with an updated type.
"""
function set_geometry(cascade, ::Type{Violin}; kwargs...)
    return _set_geometry(cascade, Violin, Poly, Coloring; style=:fill, kwargs...)
end

function set_geometry(cascade, ::Type{Vertical}; kwargs...)
    return _set_geometry(cascade, Vertical, Box, Blending;
        style=:fill,
        subdivide=true,
        space=true, 
        kwargs...,
    )
end

function set_geometry(cascade, ::Type{Horizontal}; kwargs...)
    return _set_geometry(cascade, Horizontal, Box, Coloring;
        alpha=length(cascade),
        style=:fill,
        subdivide=false,
        space=true,
        kwargs...,
    )
end


function set_geometry(cascade, ::Type{Parallel}; slope::Bool=true, kwargs...)
    return _set_geometry(cascade, Parallel, Line, Coloring;
        quantile = convert(Float64, slope),
        alpha = length(cascade),
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
function _set_geometry(cascade::Cascade{Data}, Geometry, Shape, Color;
    colorcycle::Bool=false,
    kwargs...,
)
    position = _calculate_position(cascade, Geometry; kwargs...)
    sgn = sign(cascade)

    attr = _define_from(Shape, Color, position, sgn; style=:fill, kwargs...)
    label = get_label.(collect_data(cascade))

    annot = _define_annotation(cascade, geometry; kwargs...)

    data = Geometry.(label, attr, length(cascade), annot)

    return Cascade(
        start = set_hue!(first(data), "black"),
        stop = set_hue!(last(data), "black"),
        steps = colorcycle ? set_hue!.(data[2:end-1], cascade.permutation) : data[2:end-1],
        # start = first(data),
        # stop = last(data),
        # steps = data[2:end-1],
        permutation = cascade.permutation,
        correlation = cascade.correlation,
        ispermuted = cascade.ispermuted,
        iscorrelated = cascade.iscorrelated,
    )
end


function _set_geometry(plot::Plot{Data}, Geometry::DataType, args...; kwargs...)
    cascade = _set_geometry(plot.cascade, Geometry, args...; kwargs...)
    return Plot(cascade, plot.axes)
end