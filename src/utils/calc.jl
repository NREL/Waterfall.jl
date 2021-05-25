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
function cumulative_x(shift::Float64=-0.5; subdivide=true, samples=1, space=true, steps, kwargs...)
    ROW, COL = steps, (subdivide ? samples : 1)
    extend = -sign(-0.5-shift) * (0.5*SEP * !space * !subdivide)

    wo = width(steps)
    wi = wo/COL

    Wo = fill(wo, (ROW,1))
    Wi = fill(wi, (1,COL))
    dWo = fill(SEP, (ROW,1))
    
    L = lower_triangular(ROW)
    U = upper_triangular(COL)

    dx = Wi*(U+shift*I)
    x = (L-I)*Wo + L*dWo .+ extend
    result = x .+ dx

    return subdivide ? result : hcat(fill(result, samples)...)
end

function cumulative_x(data::Array{Data,1}, args...; kwargs...)
    STEPS, SAMPLES = size(get_value(data))
    return cumulative_x(args...; steps=STEPS, samples=SAMPLES, kwargs...)
end

cumulative_x(args...) = _cumulative(cumulative_x, args...)


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

cumulative_y(args...) = _cumulative(cumulative_y, args...)


"Helper function for different types of calculation inputs"
_cumulative(fun::Function, cascade::Cascade, args...) = fun(collect_data(cascade), args...)
_cumulative(fun::Function, data::Vector{Data}, args...) = fun(get_value(data), args...)


"""
    calculate_mean()
"""
calculate_mean(vec::Vector{T}) where T <: Real = Statistics.mean(vec)
calculate_mean(mat::Matrix{T}; dims=2) where T <: Real = Statistics.mean(mat; dims=dims)

function calculate_mean(cascade::Cascade{Data}; kwargs...)
    data = collect_data(cascade)
    label = get_label.(data)
    value = calculate_mean(get_value(data))
    return Cascade{Data}(value, label)
end

function calculate_mean(plot::Plot{Data}; kwargs...)
    value = calculate_mean(plot.cascade; kwargs...)
    return Plot{Horizontal}(Cascade{Horizontal}(value), plot.xaxis, plot.yaxis)
end

# calculate_mean(args...; kwargs...) = _calculate(calculate_mean, args...; kwargs...)


"""
"""
function calculate_quantile(cascade::Cascade{Data}, p::Float64; kwargs...)
    # Calculate values an redefine cascade.
    data = collect_data(cascade)
    label = get_label.(data)
    value = Statistics.quantile!.(copy.(get_value.(data)), p; kwargs...)
    return Cascade{Data}(value, label)
end

function calculate_quantile(plot::Plot{Data}, p::Float64; kwargs...)
    cascade = calculate_quantile(plot.cascade, p; kwargs...)
    plot = Plot{Horizontal}(Cascade{Horizontal}(cascade, p), plot.xaxis, plot.yaxis)
end

# calculate_quantile(args...; kwargs...) = _calculate(calculate_quantile, args...; kwargs...)


"""
"""
function _calculate(fun::Function, plot::Plot{Data}, args...; kwargs...)
    value = fun(plot.cascade, args...; kwargs...)
    return Plot{Horizontal}(Cascade{Horizontal}(value), plot.xaxis, plot.yaxis)
end


"""
"""
calculate_kde(v::Vector{T}) where T <: Real = KernelDensity.kde(v)
calculate_kde(fun::Function, data::Data) = calculate_kde(fun(data))