get_order(x::T) where T<:Real = parse(Int, match(r"e(.*)", Printf.@sprintf("%e", x))[1])


"""
    scale_for
"""
function scale_for(cascade, ::Type{Violin}; kwargs...)
    v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
    v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
    
    vkde = calculate(v2, KernelDensity.kde)
    vlims = vlim(v1; kwargs...)

    xl, xr = scale_x(vkde; kwargs...)
    y = scale_y(vkde; vlims...)

    return vectorize(Luxor.Point.(hcat(xl,xr), hcat(y,y)))
end


function scale_for(cascade, ::Type{T}; kwargs...) where T<:Geometry
    v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
    v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
    
    vlims = vlim(v1; kwargs...)

    y1 = scale_y(v1; vlims...)
    y2 = scale_y(v2; vlims...)

    x1, x2 = scale_x(cascade; kwargs...)

    return vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2))
end


function scale_for(cascade, ::Type{T}, fun::Function, args...; kwargs...) where T<:Geometry
    vlims = vlim(cascade; kwargs...)
    # cout = calculate(copy(cascade), fun, args...)
    return scale_for(calculate(copy(cascade), fun, args...), T; vlims...)
end


"""
    scale_x(data::Data, quantile::Real=1; kwargs...)
This function scales 
"""
function scale_x( ;
    steps,
    shift::Float64=-0.5,
    nsample=1,
    subdivide=true,
    space=true,
    kwargs...,
)
    ROW, COL = steps, (subdivide ? nsample : 1)
    extend = -sign(-0.5-shift) * (0.5*SEP * !space * !subdivide)

    wstep = width(steps)
    wsample = wstep/COL

    Wstep = fill(wstep, (ROW,1))
    Wsample = fill(wsample, (1,COL))
    dWo = fill(SEP, (ROW,1))
    
    L = matrix(LinearAlgebra.UnitLowerTriangular, ROW; value=1)
    U = matrix(LinearAlgebra.UnitUpperTriangular, COL; value=1)

    dx = Wsample*(U+shift*I)
    x = (L-I)*Wstep + L*dWo .+ extend
    result = x .+ dx

    return subdivide ? result : hcat(fill(result, nsample)...)
end


function scale_x(lst::AbstractArray{T}; kwargs...) where T <: KernelDensity.UnivariateKDE
    v = matrix(getfield.(lst,:density))

    ROW, COL = size(v)
    xmid = scale_x( ; steps=ROW, kwargs...)

    w = width(ROW)
    vmax = maximum(v; dims=2)
    factor = matrix(fill.(0.5 * w ./ vmax, COL))

    xl = xmid .- (factor .* v)
    xr = xmid .+ (factor .* v)
    return xl, xr
end


function scale_x(data::Vector{Data}; quantile=1.0, kwargs...)
    STEPS, SAMPLES = size(get_value(data))
    x1 = scale_x( ; steps=STEPS, nsample=SAMPLES, shift=-(1-(1-quantile)/2), kwargs...)
    x2 = scale_x( ; steps=STEPS, nsample=SAMPLES, shift=   -(1-quantile)/2,  kwargs...)
    return x1, x2
end


scale_x(cascade::T; kwargs...) where T <: Cascade = scale_x(collect_data(cascade); kwargs...)


"""
    scale_y(data::Data)
"""
function scale_y(v::AbstractArray; kwargs...)
    vmin, vmax, vscale = vlim(v; kwargs...)
    return -vscale * (max.(v,vmin) .- vmax)
end

function scale_y(lst::AbstractArray{T}; kwargs...) where T <: KernelDensity.UnivariateKDE
    return matrix(scale_y.(getfield.(lst,:x); kwargs...))
end

scale_y(cascade::Cascade{Data}; kwargs...) = scale_y(collect_data(cascade); kwargs...)
scale_y(data::Vector{Data}; kwargs...) = scale_y(get_value(data); vlim(data)...)


"""
    vlim(data::Vector{Data})
This function returns parameters that define value dimensions as they will be used to label
y-axis ticks.

# Returns
- `vmin::Float64`: (rounded) minimum data value
- `vmax::Float64`: (rounded) minimum data value
- `vscale::Float64`: scaling factor to convert value coordinates to drawing coordinates.
"""
function vlim(mat::AbstractArray; vmin=missing, vmax=missing, kwargs...)
    mat = dropzero(mat)
    order = minimum(get_order.(mat))

    vmin = coalesce(vmin, floor(minimum(mat) - 0.5*exp10(order-1)))
    vmax = coalesce(vmax, ceil(maximum(mat) + 0.5*exp10(order-1)) + 0.5*exp10(order-1))
    
    vscale = HEIGHT/(vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


function vlim(data::Vector{Data}; kwargs...)
    return vlim(Statistics.cumsum(get_value(data); dims=1); kwargs...)
end

vlim(cascade::Cascade{Data}; kwargs...) = vlim(collect_data(cascade); kwargs...)