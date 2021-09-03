import Base

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
function matrix(lst::Vector{T}) where T<:AbstractMatrix
    !isvector(first(lst)) && error("Error in concatenating the list")

    # If the input is a list of *COLUMN* matrices,
    findmin(size(first(lst)))[2] == 1 && (lst = LinearAlgebra.adjoint.(lst))

    return _matrix(lst)
end

matrix(lst) = lst
matrix(lst::Vector{T}) where T<:Union{Vector,Real} = _matrix(lst)
matrix(lst::Matrix{T}) where T<:Union{Vector,Real} = isvector(lst) && _matrix(lst)

matrix(T::UnionAll, N; value=0) = T(fill(value, N, N))
matrix(T::LinearAlgebra.UniformScaling, N) = T(N)*1.0

_matrix(lst) = convert(Matrix, cat(lst...; dims=2)')


"""
    vectorize(x::Any)
This method returns a list of vectors.

```jldoctest
julia> mat =  [[1,4]  [2,5]  [3,6]]
2×3 Array{Int64,2}:
 1  2  3
 4  5  6

julia> vectorize(mat)
2-element Array{Array{Int64,1},1}:
 [1, 2, 3]
 [4, 5, 6]
```
"""
vectorize(x::Vararg{Any}) = vectorize(Tuple.(hcat.(x...)))
vectorize(x::Matrix) = collect.(collect(eachrow(x)))
vectorize(x::Vector) = x
vectorize(x::Any) = [x;]


"These methods extend `Base.sign` to `Waterfall` types."
Base.sign(data::T) where T <: Data = sign.(get_value(data))
Base.sign(cascade::Cascade{Data}) = sign.(collect_data(cascade))


"These methods extend `Base.length` to `Waterfall` types."
Base.length(x::Data) = length(x.order)
Base.length(x::T) where T <: Geometry = x.nsample
Base.length(x::T) where T <: Cascade = length(x.start)
Base.length(x::T) where T <: Plot = length(x.cascade)
Base.length(x::T) where T <: Shape = x.position
Base.length(x::Coloring) = 1
Base.length(x::Blending) = 1
# Base.length(x::T) where T <: Axis = length(x.ticks)


"These methods extend `Base.value` to `Waterfall` Types"
Base.values(x::Data) = _values(x)
Base.values(x::Cascade) = _values(x)
Base.values(x::Axis) = _values(x)
Base.values(x::Plot) = _values(x)
Base.values(x::Coloring) = _values(x)
Base.values(x::Blending) = _values(x)
_values(x::T) where T <: Any = Tuple([getproperty(x, f) for f in fieldnames(T)])


"These methods extend `Base.copy` to `Waterfall` and `Luxor` Types"
Base.copy(x::Symbol) = x
Base.copy(x::Axis) = _copy(x)
Base.copy(x::Data) = _copy(x)
Base.copy(x::Vector{Data}) = _copy.(x)

Base.copy(x::Luxor.Point) = _copy(x)
Base.copy(x::Tuple{Luxor.Point,Luxor.Point}) = _copy.(x)

Base.copy(x::Luxor.RGB) = _copy(x)
Base.copy(x::Vector{Luxor.RGB}) = _copy.(x)
Base.copy(x::Coloring) = _copy(x)
Base.copy(x::Blending) = _copy(x)

Base.copy(x::T) where T<:Shape = T(copy.(_values(x))...)
Base.copy(x::Cascade) = Cascade(copy.(_values(x))...)
Base.copy(x::Plot) = Plot(copy.(_values(x))...)

_copy(x::T) where T <: Any = T(values(x)...)


"""
    Base.minimum(pos::Vector{Luxor.Point}; kwargs...)
    Base.minimum(pos::Vector{Tuple}; kwargs...)
These methods extend `Base.minimum` to find the minimum `x` or `y` value of a list of points
or list of pairs of points, with `dims` indicating whether to return the `x` (`dims=1`) or
`y` (`dims=2`) element.
"""
Base.maximum(lst::Vector{T}; dims) where T<:Luxor.Point = maximum(getindex.(lst,dims))
Base.maximum(lst::Vector{T}; kwargs...) where T<:Tuple = maximum(vcat(collect.(lst)...); kwargs...)


"""
    Base.maximum(pos::Vector{Luxor.Point}; kwargs...)
    Base.maximum(pos::Vector{Tuple}; kwargs...)
These methods extend `Base.maximum` to find the maximum `x` or `y` value of a list of points
or list of pairs of points, with `dims` indicating whether to return the `x` (`dims=1`) or
`y` (`dims=2`) element.
"""
Base.minimum(lst::Vector{T}; dims) where T<:Luxor.Point = minimum(getindex.(lst,dims))
Base.minimum(lst::Vector{T}; kwargs...) where T<:Tuple = minimum(vcat(collect.(lst)...); kwargs...)


mid(lst; kwargs...) = Statistics.mean([minimum(lst; kwargs...), maximum(lst; kwargs...)])


"This function returns all permutations of the elements in the input vectors or vector of vectors"
permute(x::Vector{Vector{T}}) where T<: Any = permute(x...)
permute(x::Vararg{Any}) = vec(collect(collect.(Iterators.product(x...))))


"This function returns all of the ways to combine the elements in `lst`. At the moment,
due to memory size, this will truncate to a maximum length of `maxlen=6`."
function combinate(lst::AbstractArray; maxlen=6)
    lst = collect(lst)[1:max(length(lst),maxlen)]
    x = fill(collect(lst), length(lst))
    x = permute(x)
    return sort(x[vec(length.(unique.(x)).==length.(x))])
end


"""
    Base.convert(::Type{SparseArrays.SparseMatrixCSC}, order::AbstractVector{Int})
This method converts an `Nx1` list of indices into a sparce matrix ``S`` that,
if multiplied by a matrix `A`:
- ``S \\cdot A`` will reorder the **rows** of ``A`` to `order`
- ``A \\cdot S`` will reorder the **columns** of ``A`` to `order`

```jldoctest
julia> order = [1,3,2];

julia> sparse_matrix = convert(SparseArrays.SparseMatrixCSC, order)
3×3 SparseArrays.SparseMatrixCSC{Int64,Int64} with 3 stored entries:
  [1, 1]  =  1
  [3, 2]  =  1
  [2, 3]  =  1

julia> Matrix(sparse_matrix)
  3×3 Array{Int64,2}:
   1  0  0
   0  0  1
   0  1  0

julia> sparse_matrix * collect(1:length(order)) == order
   true
```


    convert(::Type{DataFrames.DataFrame}, cascade::Cascade)
This method converts `cascade` into a "sample-by-step"-dimension DataFrame with the step
labels as property property names.


    Base.convert(::Type{Matrix}, lst::AbstractVector; dims=2)
"""
function Base.convert(::Type{SparseArrays.SparseMatrixCSC}, order::T) where T <: AbstractVector{Int}
    N = length(order)
    return SparseArrays.sparse(1:N, order, fill(1,N))
end


function Base.convert(::Type{DataFrames.DataFrame}, x::Cascade)
    data = collect_data(x)
    sublabel = getindex.(match.(r"(\S*)", get_sublabel.(data)),1)
    label = get_label.(data)
    [label[ii] = "$(label[ii]) ($(sublabel[ii]))" for ii in [1,length(data)]]

    value = get_value(data)

    return DataFrames.DataFrame(value', label; makeunique=true)
end


"""
    isinteger(x::String)
This method returns true if `x` can be parsed as an integer.
"""
Base.isinteger(x::String) = getindex(match(r"(\d*)", x),1)==x


"""
    tryinteger(x::String)
This method parses `x` as an `Int64` if possible, and otherwise returns `x`.

    tryinteger(lst::Vector{String})
This methods `lst` as `Vector{Int64}` if this is possible for **all** array elements.
"""
tryinteger(x::String) = isinteger(x) ? parse(Int64,x) : x
tryinteger(lst::AbstractArray) = all(isinteger.(lst)) ? parse.(Int64,lst) : lst


"""
    swapat!(lst::AbstractArray, a, b)
This function swaps the values of `lst` at elements `a` and `b`.
"""
function swapat!(lst::AbstractArray, a::Int, b::Int)
    tmp = lst[a]
    lst[a] = lst[b]
    lst[b] = tmp
    return lst
end