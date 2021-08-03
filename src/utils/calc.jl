
function calculate!(cascade::Cascade{Data}, args...; kwargs...)
    data = collect_data(cascade)
    set_value!(data, calculate(data, args...; kwargs...))
    return cascade
end

function calculate(v::AbstractMatrix, fun::Function; dims=2, kwargs...)
    return update_stop!(fun(v; dims=dims))
end

function calculate(v::AbstractMatrix, fun::Function, args...; dims=2, kwargs...)
    N = size(v,1)
    return reshape(update_stop!(fun.(vectorize(v), args...)), N, 1)
end

calculate(cascade, args...; kwargs...) = calculate!(copy(cascade), args...; kwargs...)
calculate(data::Vector{Data}, args...; kwargs...) = calculate(get_value(data), args...; kwargs...)



"Returns an NxN lower-triangular matrix."
lower_triangular(N::Integer; kwargs...) = lower_triangular(N, 1; kwargs...)

function lower_triangular(N::Integer, val; unit=true)
    mat = fill(val, N, N)
    return unit ? LinearAlgebra.UnitLowerTriangular(mat) : LinearAlgebra.LowerTriangular(mat)
end

"Returns an NxN upper-triangular matrix."
upper_triangular(N::Integer; kwargs...) = upper_triangular(N, 1; kwargs...)

function upper_triangular(N::Integer, val; unit=true)
    mat = fill(val, N, N)
    return unit ? LinearAlgebra.UnitUpperTriangular(mat) : LinearAlgebra.UpperTriangular(mat)
end


"Drops zero values."
dropzero(mat::Array{T,2}) where T <: Real = mat[all.(eachrow(mat.!==0.)),:]
dropzero(vec::Array{T,1}) where T <: Real = vec[vec.!==0.0]


"""
"""
function cumulative_v(v::AbstractArray; shift=0.0, kwargs...)
    N = size(v,1)
    L = lower_triangular(N) + shift*I
    return L * v
end

cumulative_v(x::Cascade{Data}; kwargs...) = cumulative_v(get_value(collect_data(x)); kwargs...)


# """
# """
# function cumulative_v!(x::Cascade; kwargs...)
#     v1 = cumulative_v(x; shift=-1.0, kwargs...)
#     v2 = cumulative_v(x; shift= 0.0, kwargs...)
#     return v1, v2
# end


"""
This function calculates the graphical width of each bar based on the number of cascade
steps, ``N_{step}``:
```math
w_{step} = \\dfrac{WIDTH - \\left(N_{step}+1\\right) SEP}{N_{step}}
```
"""
width(steps::Integer; space=SEP, margin=SEP/2) = (WIDTH - 2*margin - space*steps)/steps


"""
    cumulative_x( ; kwargs...)
"""
function cumulative_x( ;
    steps,
    shift::Float64=-0.5,
    samples=1,
    subdivide=true,
    space=true,
    kwargs...,
)
    ROW, COL = steps, (subdivide ? samples : 1)
    extend = -sign(-0.5-shift) * (0.5*SEP * !space * !subdivide)

    wstep = width(steps)
    wsample = wstep/COL

    Wstep = fill(wstep, (ROW,1))
    Wsample = fill(wsample, (1,COL))
    dWo = fill(SEP, (ROW,1))
    
    L = lower_triangular(ROW)
    U = upper_triangular(COL)

    dx = Wsample*(U+shift*I)
    x = (L-I)*Wstep + L*dWo .+ extend
    result = x .+ dx

    return subdivide ? result : hcat(fill(result, samples)...)
end

function cumulative_x(data::Vector{Data}; kwargs...)
    STEPS, SAMPLES = size(get_value(data))
    return cumulative_x( ; steps=STEPS, samples=SAMPLES, kwargs...)
end

cumulative_x(args...; kwargs...) = _cumulative(cumulative_x, args...; kwargs...)


# """
#     cumulative_y(v::VecOrMat)
#     cumulative_y(v::VecOrMat, shift::Float64)
# This function calculates cumulative sum at some fraction ``c\\in[-1,0]`` of the current
# cascade step. If ``c=0`` (default), the sum will be calculated for the end of the current
# step. If ``c=-1``, the sum will be calculated for the beginning of the current step.
#     ```math
#     v_{beg} = (L-cI) \\cdot v
#     ```
# Change the value of ``c`` by passing the argument `shift=0`.
# """
# function cumulative_y(v::VecOrMat{T}, shift::Real=0.0) where T <: Real
#     result = (lower_triangular(size(v,1))+shift*I) * v
#     result[abs.(result) .< 1E-8] .= 0
#     return result
# end

# cumulative_y(args...) = _cumulative(cumulative_y, args...)


"Helper function for different types of calculation inputs"
_cumulative(fun::Function, cascade::Cascade, args...; kwargs...) = fun(collect_data(cascade), args...; kwargs...)
# _cumulative(fun::Function, data::Vector{Data}, args...; kwargs...) = fun(get_value(data), args...; kwargs...)


# """
#     calculate_mean()
# """
# calculate_mean(vec::Vector{T}) where T <: Real = Statistics.mean(vec)
# calculate_mean(mat::Matrix{T}; dims=2) where T <: Real = Statistics.mean(mat; dims=dims)

# function calculate_mean(cascade::Cascade{Data}; kwargs...)
#     data = collect_data(cascade)
#     label = get_label.(data)
#     value = calculate_mean(get_value(data))
#     return Cascade{Data}(value, label)
# end

# function calculate_mean(plot::Plot{Data}; kwargs...)
#     value = calculate_mean(plot.cascade; kwargs...)
#     return Plot{Horizontal}(Cascade{Horizontal}(value), plot.xaxis, plot.yaxis)
# end

# # calculate_mean(args...; kwargs...) = _calculate(calculate_mean, args...; kwargs...)


# """
# """
# function calculate_quantile(cascade::Cascade{Data}, p::Float64; kwargs...)
#     # Calculate values an redefine cascade.
#     data = collect_data(cascade)
#     label = get_label.(data)
#     value = Statistics.quantile!.(copy.(get_value.(data)), p; kwargs...)
#     return Cascade{Data}(value, label)
# end

# function calculate_quantile(plot::Plot{Data}, p::Float64; kwargs...)
#     cascade = calculate_quantile(plot.cascade, p; kwargs...)
#     plot = Plot{Horizontal}(Cascade{Horizontal}(cascade, p), plot.xaxis, plot.yaxis)
# end

# # calculate_quantile(args...; kwargs...) = _calculate(calculate_quantile, args...; kwargs...)


# """
# """
# function _calculate(fun::Function, plot::Plot{Data}, args...; kwargs...)
#     value = fun(plot.cascade, args...; kwargs...)
#     return Plot{Horizontal}(Cascade{Horizontal}(value), plot.xaxis, plot.yaxis)
# end


# """
# """
calculate_kde(v::Vector{T}) where T <: Any = KernelDensity.kde(v)
# calculate_kde(fun::Function, data::Data) = calculate_kde(fun(data))