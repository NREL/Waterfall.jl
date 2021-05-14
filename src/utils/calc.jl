"Returns an NxN lower-triangular matrix."
upper_triangular(N::Integer) = LinearAlgebra.UnitUpperTriangular(Int.(ones(N,N)))

"Returns an NxN upper-triangular matrix."
lower_triangular(N::Integer) = LinearAlgebra.UnitLowerTriangular(Int.(ones(N,N)))

"Drops zero values."
dropzero(mat::Array{T,2}) where T <: Real = mat[all.(eachrow(mat.!==0.)),:]
dropzero(vec::Array{T,1}) where T <: Real = vec[vec.!==0.0]

width(steps::Integer) = (WIDTH-(steps+1)*SEP)/steps


"""
    cumulative_x(shift::Float64)
"""
function cumulative_x(shift::Float64=-0.5; subdivide=true, samples=1, steps, kwargs...)
    ROW, COL = steps, (subdivide ? samples : 1)

    wo = width(steps)
    wi = wo/COL

    Wo = fill(wo, (ROW,1))
    Wi = fill(wi, (1,COL))
    dWo = fill(SEP, (ROW,1))

    L = lower_triangular(ROW)
    U = upper_triangular(COL)

    dx = Wi*(U+shift*I)
    x = (L-I)*Wo + L*dWo
    result = x .+ dx

    return subdivide ? result : hcat(fill(result, samples)...)
end

function cumulative_x(data::Array{Data,1}, args...; kwargs...)
    STEPS, SAMPLES = size(get_value(data))
    return cumulative_x(args...; steps=STEPS, samples=SAMPLES, kwargs...)
end

cumulative_x(args...) = _calculate(cumulative_x, args...)


"""
    cumulative_y(v::VecOrMat)
    cumulative_y(v::VecOrMat, shift::Float64)
This function calculates cumulative sum at some fraction ``c\\in[-1,0]`` of the current
cascade step. If ``c=0`` (default), the sum will be calculated for the end of the current
step. If ``c=-1``, the sum will be calculated for the beginning of the current step.
    ```math
    v_{beg} = (L-cI) \\cdot v
    ```
Change the value of ``c`` by passing the argument `shift=0`.
"""
function cumulative_y(v::VecOrMat{T}, shift::Real=0.0) where T <: Real
    result = (lower_triangular(size(v,1))+shift*I) * v
    result[abs.(result) .< 1E-8] .= 0
    return result
end

cumulative_y(args...) = _calculate(cumulative_y, args...)


"Helper function for different types of calculation inputs"
_calculate(fun::Function, cascade::Cascade, args...) = fun(collect_data(cascade), args...)
_calculate(fun::Function, data::Vector{Data}, args...) = fun(get_value(data), args...)


calculate_mean(v::Vector{T}) where T <: Real = Statistics.mean(v)
calculate_mean(mat::Matrix{T}; dims=2) where T <: Real = Statistics.mean(mat; dims=dims)

function calculate_mean(cascade::Cascade{Data})
    data = collect_data(cascade)
    label = get_label.(data)
    value = calculate_mean(get_value(data))
    return Cascade{Data}(value, label)
end


"""
"""
calculate_kde(v::Vector{T}) where T <: Real = KernelDensity.kde(v)
calculate_kde(fun::Function, data::Data) = calculate_kde(fun(data))

"""
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