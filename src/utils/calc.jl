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


"""
    matrix(mat; )

```jldoctest
julia> matrix(1:3)
3×1 Array{Int64,2}:
 1
 2
 3
```
"""
matrix(lst) = lst
matrix(lst::Vector{T}) where T<:Union{Vector,Real} = _matrix(lst)
matrix(lst::Matrix{T}) where T<:Union{Vector,Real} = isvector(lst) && _matrix(lst)

function matrix(lst::Vector{T}) where T<:AbstractMatrix
    !isvector(first(lst)) && error("Error in concatenating the list")

    # If the input is a list of *COLUMN* matrices,
    findmin(size(first(lst)))[2] == 1 && (lst = LinearAlgebra.adjoint.(lst))

    return _matrix(lst)
end

_matrix(lst) = convert(Matrix, cat(lst...; dims=2)')


"Check that there are two dimensions, MAXIMUM, and that one of these dimensions is ONE."
isvector(mat::AbstractMatrix) = length(size(mat)) == 2 && (1 in size(mat))
isvector(vec::AbstractVector) = true


# "Returns an NxN lower-triangular matrix."
# lower_triangular(N::Integer; kwargs...) = lower_triangular(N, 1; kwargs...)

# function lower_triangular(N::Integer, val; unit=true)
#     mat = fill(val, N, N)
#     return unit ? LinearAlgebra.UnitLowerTriangular(mat) : LinearAlgebra.LowerTriangular(mat)
# end

# "Returns an NxN upper-triangular matrix."
# upper_triangular(N::Integer; kwargs...) = upper_triangular(N, 1; kwargs...)

# function upper_triangular(N::Integer, val; unit=true)
#     mat = fill(val, N, N)
#     return unit ? LinearAlgebra.UnitUpperTriangular(mat) : LinearAlgebra.UpperTriangular(mat)
# end


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