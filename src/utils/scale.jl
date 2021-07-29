get_order(x::T) where T<:Real = parse(Int, match(r"e(.*)", Printf.@sprintf("%e", x))[1])


"""
"""
function scale_point(cascade::Cascade, quantile::T, args...; kwargs...) where T <: Real
    v1, v2 = cumulative_v!(cascade; kwargs...)
    
    # Allows for diy vlims.
    vlims = vlim(v1; kwargs...)

    y1 = scale_y(v1; vlims...)
    y2 = scale_y(v2; vlims...)

    x1, x2 = scale_x(cascade, quantile; kwargs...)

    return vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2))
end


"""
    scale_x(data::Data, quantile::Real=1; kwargs...)
This function scales 
"""
function scale_x(data::Vector{Data}, quantile::Real=1; kwargs...)
    x1 = cumulative_x(data, -(1-(1-quantile)/2); kwargs...)
    x2 = cumulative_x(data,    -(1-quantile)/2; kwargs...)
    return x1, x2
end

scale_x(cascade::T, args...; kwargs...) where T <: Cascade = scale_x(collect_data(cascade), args...; kwargs...)


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


function scale_kde(cascade::Cascade; kwargs...)
    v1, v2 = cumulative_v!(cascade; permute=false, kwargs...)
    value = calculate_kde.(vectorize(convert.(Float64, v2)))

    data = collect_data(cascade)
    vlims = vlim(data; kwargs...)

    y = getproperty.(value,:x)
    y = convert(Matrix, scale_y.(y; vlims...))

    xl, xr = scale_density(value; steps=length(data),)

    x, y = hcat(xl,xr), hcat(y,y)
    return vectorize(Luxor.Point.(x,y))
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
function vlim(mat::Matrix; vmin=missing, vmax=missing, kwargs...)
    if ismissing(vmin)*ismissing(vmax)
        vmax = 22.5
        vmin = 13.0
    end
    
    vscale = HEIGHT/(vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


function vlim(data::Vector{Data}; kwargs...)
    return vlim(get_value(data); kwargs...)
end

calculate_kde(v::Vector{T}) where T <: Real = KernelDensity.kde(v)