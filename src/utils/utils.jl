import Base

init(T::UnionAll, N) = T(fill(0.0, N, N))
init(T::LinearAlgebra.UniformScaling, N) = T(N)*1.0

vectorize(x::Matrix) = collect.(collect(eachrow(x)))
vectorize(mat...) = vectorize(Tuple.(hcat.(mat...)))

get_x(x::KernelDensity.UnivariateKDE) = x.x
get_x(args...) = _get(get_x, args...)

get_density(x::KernelDensity.UnivariateKDE) = x.density
get_density(args...) = _get(get_density, args...)


Base.sign(data::T) where T <: Data = sign.(get_value(data))
Base.sign(cascade::Cascade{Data}) = sign.(collect_data(cascade))

Base.length(x::Data) = length(x.order)
Base.length(x::T) where T <: Geometry = x.nsample
Base.length(x::T) where T <: Cascade = length(x.start)
Base.length(x::T) where T <: Plot = length(x.cascade)
# Base.length(x::T) where T <: Axis = length(x.ticks)


Base.values(x::Data) = _values(x)
Base.values(x::Cascade) = _values(x)
Base.values(x::Axis) = _values(x)
Base.values(x::Plot) = _values(x)
_values(x::T) where T <: Any = Tuple([getproperty(x, f) for f in fieldnames(T)])

Base.copy(x::Axis) = _copy(x)
Base.copy(x::Data) = _copy(x)
Base.copy(x::Vector{Data}) = _copy.(x)
Base.copy(x::Cascade) = Cascade(copy.(_values(x))...)
Base.copy(x::Plot) = Plot(copy.(_values(x))...)
_copy(x::T) where T <: Any = T(values(x)...)

Base.maximum(lst::Vector{T}; dims) where T<:Luxor.Point = maximum(getindex.(lst,dims))
Base.maximum(lst::Vector{T}; kwargs...) where T<:Tuple = maximum(vcat(collect.(lst)...); kwargs...)

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

# """
# This function returns a filename
# """
# function filename(p::Plot{T}, stat; opacity="", distribution=:normal, frame=missing,
# ) where T <: Geometry
#     dir = joinpath(FIG_DIR,lowercase(string(T)))
#     fig = Printf.@sprintf("%s_n%02.0f_%s", T, length(p), distribution)

#     !isempty(stat) && (fig = Printf.@sprintf("%s_%s", fig, _write_stat(stat)))

#     if !ismissing(frame)
#         dir = joinpath(dir, fig)
#         fig = Printf.@sprintf("frame%02.0f", frame)
#     end

#     !isdir(dir) && mkpath(dir)
#     return joinpath(dir, lowercase(fig * ".png"))
# end


# function filename(p::Plot{T}, stat::AbstractArray; kwargs...) where T <: Geometry
#     stat = copy(stat)
#     iitup = typeof.(stat) .<: Tuple
#     stat[iitup] .= sort(stat[iitup])
#     return filename(p, string(string.(_write_stat.(stat),"_")...)[1:end-1]; kwargs...)
# end


# function filename(p::Plot{T}; opacity="", distribution=:normal, frame=missing, mean
# ) where T <: Geometry

#     dir = joinpath(FIG_DIR,lowercase(string(T)))
#     fig = Printf.@sprintf("%s_n%02.0f_%s_mean%g", T, length(p), distribution, mean)

#     if !ismissing(frame)
#         dir = joinpath(dir, fig)
#         fig = Printf.@sprintf("frame%02.0f", frame)
#     end

#     !isdir(dir) && mkpath(dir)
#     return joinpath(dir, lowercase(fig * ".png"))
# end


# ""
# _write_stat(x::String) = x
# _write_stat(x::Tuple) = x[1] * Printf.@sprintf("%03.0f", x[2]*100)

# _label_stat(x::String) = x
# _label_stat(x::Tuple) = ordinal(x[2])

# function ordinal(x::Float64)
#     suffix = " %ile"
#     str = Printf.@sprintf("%.0f", x*100)
#     return if str[end]=='1'; str * "st" * suffix
#     elseif str[end]=='2';    str * "nd" * suffix
#     else;                    str * "th" * suffix
#     end
# end











# function draw_highlight(p::Plot{Data}, stat; kwargs...)
#     phighlight = highlight(p, stat)
#     draw(phighlight; style=:stroke, opacity=1.0)

# end