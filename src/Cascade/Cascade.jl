mutable struct Cascade{T<:Sampling}
    start::T
    stop::T
    steps::Vector{T}
    permutation::Vector
    correlation::AbstractMatrix
    ispermuted::Bool
    iscorrelated::Bool
end

function Cascade( ; start, stop, steps, correlation, permutation, ispermuted, iscorrelated)
    return Cascade(start, stop, steps, permutation, correlation, ispermuted, iscorrelated)
end


"""
    collect_data(x::Cascade)
This function returns a list of all [`Data`](@ref) Types stored in `x`,
ordered [`x.start; x.steps, x.stop]`.
"""
collect_data(x::Cascade) = Vector{}([x.start; x.steps; x.stop])


"""
    collect_correlation(x::Cascade)
This function extends the correlation matrix ``A \\in \\mathbb{R}^{N,N}`` stored in
`x.correlation` by defining ``A' \\in \\mathbb{R}^{N+2,N+2}`` to account for
`x.start` and `x.stop` for consistent dimensionality with the vector returned by
[`collect_data`](@ref).

```math
A' = 
\\begin{pmatrix}
1 &   &     \\
    & A &   \\
    &   & 1
\\end{pmatrix}
```

# Returns
- `L::Matrix`: 
"""
function collect_correlation(x::Cascade; kwargs...)
    mat = x.correlation
    N = size(mat,1)

    L = 1.0*Matrix(I(N+2))
    L[2:N+1, 2:N+1] .= mat
    return L
end


"""
    collect_permutation(lst)
    collect_permutation(cascade)
"""
collect_permutation(lst::AbstractArray) = [1; get_permutation(lst).+1; length(lst)+2]

function collect_permutation(x::T; kwargs...) where T<:Cascade
    return collect_permutation(get_permutation(x))
end


"""
    collect_ticks(x::Cascade{Data}; kwargs...)
This function returns a list of major y-axis ticks
"""
function collect_ticks(cascade; kwargs...)
    vmin, vmax, vscale = vlim(cascade; kwargs...)
    return collect(vmin:minimum(get_order.([vmin,vmax])):vmax)
end


"""
"""
collect_value(cascade::Cascade) = get_value(collect_data(cascade))


"""
    get_permutation(idx)
    get_permutation(cascade)
"""
function get_permutation(x::Cascade)
    return x.ispermuted ? get_permutation(x.permutation) : collect(1:length(x.steps))
end

function get_permutation(idx::AbstractVector{Int})
    ordered = DataFrames.DataFrame(old=idx,)
    collapsed = DataFrames.DataFrame(old=sort(idx), new=1:length(idx))
    df = DataFrames.leftjoin(collapsed, ordered, on=:old)
    return df[:,:new]
end


"""
    get_correlation(cascade)
"""
function get_correlation(x::Cascade; kwargs...)
    return x.correlation[get_permutation(x; kwargs...), :]
end


"""
    update_stop!(x::)
This function updates `cascade.stop` or the last row of a matrix to equal the negative
of the cumulative sum of all previous values.
"""
function update_stop!(x::Cascade)
    val = collect_value(x)
    set_value!(x.stop, update_stop!(val)[end,:])
    return x
end

function update_stop!(x::Matrix)
    x[end,:] .= -Statistics.cumsum(x; dims=1)[end-1,:]
    return x
end

function update_stop!(df::DataFrames.DataFrame; value=VALUE_COL)
    df[:,value] .= -update_stop!(df[:,value])
    return df
end