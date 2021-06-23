get_order(x::T) where T<:Real = parse(Int, match(r"e(.*)", Printf.@sprintf("%e", x))[1])


"""
    scale_x(data::Data, quantile::Real=1; kwargs...)
This function scales 
"""
function scale_x(data, quantile::Real=1; kwargs...)
    x1 = Waterfall.cumulative_x(data, -(1-(1-quantile)/2); kwargs...)
    x2 = Waterfall.cumulative_x(data,    -(1-quantile)/2; kwargs...)
    return x1, x2
end


"""
    scale_y(data::Data)
"""
function scale_y(data::Vector{Data}, args...)
    y1 = scale_y(get_beginning, data, args...)
    y2 = scale_y(get_ending, data, args...)
    return y1, y2
end

Waterfall.scale_y(v::AbstractArray; vmin, vscale, vmax) = -vscale * (max.(v,vmin) .- vmax)

# function scale_y(fun::Function, data::Vector{Data})
#     vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
#     return scale_y(fun(data); vlims...)
# end

scale_y(fun::Function, cascade::Cascade) = scale_y(fun, collect_data(cascade))
scale_y(fun::Function, cascade::Cascade, vlims) = scale_y(fun, collect_data(cascade), vlims)
scale_y(fun::Function, data::Vector{Data}, vlims) = scale_y(fun(data); vlims...)


"""
    scale_kde(data::Vector{Data})
"""
function scale_kde(fun::Function, data::Vector{Data})
    value = calculate_kde.(fun, data)
    
    vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
    y = get_x(value)
    y = scale_y(y; vlims...)

    xl, xr = scale_density(value; steps=length(data),)
    return hcat(xl,xr), hcat(y,y)
end


"""
    scale_density()
"""
function scale_density(v::Matrix{T}; steps, kwargs...) where T <: Real
    ROW, COL = size(v)

    xmid = cumulative_x( ; steps=steps, kwargs...)

    w = width(steps)
    vmax = maximum(v; dims=2)
    m = hcat(fill(0.5 * w ./ vmax, COL)...)

    xl = xmid .- (m .* v)
    xr = xmid .+ (m .* v)
    return xl, xr
end

function scale_density(value::Vector; kwargs...)
    return scale_density(get_density(value); kwargs...)
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
function Waterfall.vlim(mat::Matrix)
    vmax = 22.5
    vmin = 15.0
    
    vscale = Waterfall.HEIGHT/(vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


function Waterfall.vlim(data::Vector{Data})
    return Waterfall.vlim(Waterfall.get_value(data))
end