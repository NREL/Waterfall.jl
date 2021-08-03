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
    permutation=[],
    permute=false,
    correlate=false,
    kwargs...,
)
    data = define_from(Vector{Data}, df; kwargs...)
    nstep = length(data)-2
    
    cascade = Cascade(
        start = first(data),
        stop = last(data),
        steps = data[2:end-1],
        permutation = isempty(permutation) ? collect(1:nstep) : permutation,
        correlation = random_rotation(nstep, ncor; kwargs...),
        ispermuted = false,
        iscorrelated = false,
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

# function define_from(::Type{T}, cascade::Cascade{Data}; kwargs...) where T<:Axis
#     define_from(T, collect_data(cascade), cascade.permutation; kwargs...)
# end


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
    hue = _define_hue(sign; kwargs...)
    saturation = _define_saturation( ; kwargs...)
    alpha = _define_alpha(alpha; kwargs...)
    return Coloring(hue, alpha, saturation)
end

function _define_from(::Type{Vector{Coloring}}, args...; kwargs...)
    return _define_from.(Coloring, args...; kwargs...)
end


function _define_from(::Type{Vector{Blending}}, sign, position; kwargs...)
    c1 = _define_from.(Coloring, sign; alpha=1.0, saturation=0.0)
    c2 = _define_from.(Coloring, sign; alpha=1.0, saturation=-0.5)
    # c1 = _define_from.(Coloring, sign; alpha=1.0, saturation=0.)
    # c2 = _define_from.(Coloring, sign; alpha=1.0, saturation=0.)

    xmid = getindex.([Luxor.midpoint(x...) for x in position],1)

    # SEPARATE BASED ON SIGN.
    y1 = minimum(getindex.(getindex.(position,1),2))
    y2 = maximum(getindex.(getindex.(position,2),2))

    return Blending.(Luxor.Point.(xmid, y1), Luxor.Point.(xmid, y2), c1, c2)
end













"""
"""
function _set_geometry(cascade::Cascade{Data}, Geometry, Shape, Color;
    colorcycle::Bool=false,
    kwargs...,
)
    position = _calculate_position(cascade, Geometry; kwargs...)
    sgn = sign(cascade)

    attr = _define_from(Shape, Color, position, sgn; style=:fill, kwargs...)
    label = get_label.(collect_data(cascade))

    data = Geometry.(label, attr, length(cascade), missing)

    return Cascade(
        start = set_hue!(first(data), "black"),
        stop = set_hue!(last(data), "black"),
        steps = colorcycle ? set_hue!.(data[2:end-1], get_permutation(cascade)) : data[2:end-1],
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


"""
"""
function _define_hue(x; hue=missing, colorcycleindex::Union{Missing,Integer}=missing, kwargs...)
    # Select hue.
    hue = if !ismissing(hue);           hue
    elseif !ismissing(colorcycleindex); _define_hue(colorcycleindex)
    else;                               x
    end

    # Adjust saturation.
    saturation = _define_saturation( ; kwargs...)
    return scale_saturation(parse(Luxor.Colorant, hue); kwargs...)
end

_define_hue(idx::Integer; kwargs...) = _define_hue(COLORCYCLE[idx]; kwargs...)
_define_hue(sgn::Float64; kwargs...) = _define_hue(sgn>0 ? HEX_LOSS : HEX_GAIN; kwargs...)

function _define_hue(sgn::Vector{Float64}; kwargs...)
    rgb = _define_hue.(sgn; kwargs...)
    rgb_average = [Statistics.mean(getproperty.(rgb, f)) for f in fieldnames(Luxor.RGB)]
    return scale_saturation(Luxor.Colors.RGB(rgb_average...); kwargs...)
end




function scale_saturation(rgb::Luxor.RGB; kwargs...)
    hsv = scale_saturation(Luxor.convert(Luxor.Colors.HSV, rgb); kwargs...)
    return Luxor.convert(Luxor.Colors.RGB, hsv)
end

function scale_saturation(hsv::Luxor.HSV; saturation=0.0, kwargs...)
    if saturation!==0.0
        saturation = saturation<0 ? hsv.s * (1+saturation) : (1-hsv.s)*saturation + hsv.s
        hsv = Luxor.Colors.HSV(hsv.h, saturation, hsv.v)
    end
    return hsv
end



"""
"""
function _define_alpha(N::Integer;
    factor::Real=0.25,
    fun::Function=log,
    kwargs...,
)
    return min(factor/fun(N) ,1.0)
end

_define_alpha(x; kwargs...) = x


"""
"""
_define_saturation( ; saturation=missing, kwargs...) = ismissing(saturation) ? 1.0 : saturation



# _define_from()





"""
    set_geometry()
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