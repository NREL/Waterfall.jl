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
scale_y(v::AbstractArray; vmin, vscale, vmax) = -vscale * (max.(v,vmin) .- vmax)


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


function Waterfall.scale_kde(cascade::Cascade; kwargs...)
    v1, v2 = Waterfall.cumulative_v!(cascade; permute=false, kwargs...)
    value = Waterfall.calculate_kde.(Waterfall.vectorize(convert.(Float64, v2)))
    vlims = Waterfall.vlim(data)

    y = getproperty.(value,:x)
    y = convert(Matrix, Waterfall.scale_y.(y; vlims...))

    xl, xr = Waterfall.scale_density(value; steps=length(data),)
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
function vlim(mat::Matrix)
    vmax = 22.5
    vmin = 15.0
    
    vscale = HEIGHT/(vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


function vlim(data::Vector{Data})
    return vlim(Waterfall.get_value(data))
end

calculate_kde(v::Vector{T}) where T <: Real = KernelDensity.kde(v)