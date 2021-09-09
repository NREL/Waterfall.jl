"""
"""
function calculate!(cascade::Cascade{Data}, args...; kwargs...)
    data = collect_data(cascade)
    set_value!(data, calculate(data, args...; kwargs...))
    return cascade
end


"""
"""
calculate(v::AbstractMatrix, fun::Function, args...) = matrix(fun.(vectorize(v), args...))
calculate(data::Vector{Data}, args...; kwargs...) = calculate(get_value(data), args...; kwargs...)
calculate(cascade, args...; kwargs...) = calculate!(copy(cascade), args...; kwargs...)


"Check that there are two dimensions, MAXIMUM, and that one of these dimensions is ONE."
isvector(mat::AbstractMatrix) = length(size(mat)) == 2 && (1 in size(mat))
isvector(vec::AbstractVector) = true


"Drops zero values."
dropzero(mat::Matrix) = mat[all.(eachrow(mat.>=1E-10)),:]
dropzero(vec::Vector) = vec[abs.(vec).>=1E-10]


"""
"""
function cumulative_v(v::AbstractArray; shift=0.0, kwargs...)
    N = size(v,1)
    # L = lower_triangular(N) + shift*I
    L = matrix(LinearAlgebra.UnitLowerTriangular, N; value=1.0) + shift*I
    return L * v
end

cumulative_v(x::Cascade{Data}; kwargs...) = cumulative_v(get_value(collect_data(x)); kwargs...)


"""
This function calculates the graphical width of each bar based on the number of cascade
steps, ``N_{step}``:
```math
w_{step} = \\dfrac{WIDTH - \\left(N_{step}+1\\right) SEP}{N_{step}}
```
"""
width(steps::Integer; space=SEP, margin=SEP/2) = (WIDTH - 2*margin - space*steps)/steps