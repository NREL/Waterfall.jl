import Base

vectorize(x::Matrix) = collect.(collect(eachrow(x)))
vectorize(mat...) = vectorize(Tuple.(hcat.(mat...)))

get_x(x::KernelDensity.UnivariateKDE) = x.x
get_x(args...) = _get(get_x, args...)

get_density(x::KernelDensity.UnivariateKDE) = x.density
get_density(args...) = _get(get_density, args...)


Base.sign(data::T) where T <: Data = Integer.(sign.(get_value(data)))


Base.length(x::T) where T <: Geometry = length(x.sign)
Base.length(x::T) where T <: Cascade = length(x.start)
Base.length(x::T) where T <: Axis = length(x.ticks)
Base.length(x::Plot{T}) where T<:Geometry = length(x.cascade)


Base.values(x::Data) = _values(x)
Base.values(x::Cascade) = _values(x)
Base.values(x::Axis) = _values(x)
Base.values(x::Plot) = _values(x)
_values(x::T) where T <: Any = Tuple([getproperty(x, f) for f in fieldnames(T)])


Base.copy(x::Axis) = _copy(x)
Base.copy(x::Data) = _copy(x)
Base.copy(x::Cascade) = _copy(x)
Base.copy(x::Plot) = Plot(copy.(_values(x))...)
_copy(x::T) where T <: Any = T(values(x)...)


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
"""
Base.convert(::Type{Matrix}, lst::AbstractVector; dims=2) = _convert(Matrix, lst, dims)

_convert(::Type{Matrix}, lst, dims) = LinearAlgebra.Matrix(cat(lst...; dims=dims)')


"""
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
"""
function Base.convert(::Type{SparseArrays.SparseMatrixCSC}, order::T) where T <: AbstractVector{Int}
    N = length(order)
    mat = SparseArrays.sparse(1:N, order, fill(1,N))
    # check: mat * collect(1:N) == v
    return mat
end


"""
"""
function Base.convert(::Type{Plot{T}}, x::Plot{Data}, args...; kwargs...) where T <: Geometry
    return _convert(T, x, args...; kwargs...)
end

function Base.convert(::Type{Cascade{T}}, x::Cascade{Data}, args...; kwargs...) where T <: Geometry
    return _convert(T, x, args...; kwargs...)
end


"""
"""
function _convert(::Type{Parallel}, x, args...; kwargs...)
    return _convert!(Parallel, copy(x), 1.0, args...; subdivide=false, space=false, kwargs...)
end

function _convert(::Type{Vertical}, x, args...; kwargs...)
    return _convert!(Vertical, copy(x), 1.0, args...; subdivide=true, space=true, kwargs...)
end

function _convert(::Type{Horizontal}, x, quantile::Float64, args...; kwargs...)
    return _convert!(Horizontal, copy(x), quantile, args...; subdivide=false, space=true, kwargs...)
end

function _convert(::Type{Horizontal}, x, args...; kwargs...)
    return _convert(Horizontal, copy(x), 1.0, args...; kwargs...)
end


"""
"""
function _convert!(T::DataType, x::Cascade{Data}, quantile::Float64, args...; kwargs...)

    v1, v2 = cumulative_v!(x; kwargs...)
    data = collect_data(x)
    vlims = vlim(v1)

    y1 = scale_y(v1, args...; vlims...)
    y2 = scale_y(v2, args...; vlims...)

    x1, x2 = scale_x(data, quantile; kwargs...)

    data = T.(sign.(data), vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2)))
    return Cascade(first(data), last(data), data[2:end-1], x.ncor, x.permutation, x.correlation)
end


function _convert!(T::DataType, p::Plot{Data}, args...; kwargs...)
    x = _convert!(T, p.cascade, args...; kwargs...)
    return Plot(x, set_xaxis(p.cascade), p.yaxis)
end


"""
    convert(::Type{DataFrames.DataFrame}, x::Cascade)
This function converts `x` into a "sample-by-step"-dimension DataFrame with the step labels
as property property names.
"""
function Base.convert(::Type{DataFrames.DataFrame}, x::Cascade)
    data = collect_data(x)
    sublabel = getindex.(match.(r"(\S*)", get_sublabel.(data)),1)
    label = get_label.(data)
    [label[ii] = "$(label[ii]) ($(sublabel[ii]))" for ii in [1,length(data)]]

    value = get_value(data)

    return DataFrames.DataFrame(value', label; makeunique=true)
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