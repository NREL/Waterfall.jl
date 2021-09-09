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
    collect_ticks(x::Cascade{Data}; kwargs...)
This function returns a list of major y-axis ticks
"""
function collect_ticks(cascade; kwargs...)
    vmin, vmax, vscale = vlim(cascade; kwargs...)
    return collect(vmin:minimum(get_order.([vmin,vmax])):vmax)
end


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
    val = get_value(collect_data(x))
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


"""
    correlate(v::AbstractVector, A::AbstractMatrix)
This function applies a correlation matrix `A` to the vector `v`.

```math
\\vec{x}' = \\prod_{i=N}^1 \\left(S_{i,i} A+I\\right) \\vec{x}
```

where ``S_{i,i}``, defined using [`pick`](@ref), is a sparse matrix `[i,i]=1`,
``A`` is a random rotation matrix produced by [`random_rotation`](@ref).
``S_{i,i} A`` selects the ``i^\\text{th}`` row of ``A``, which defines how steps `1:i-1`
impact step `i`. Once correlations have been applied to the `i`th step,
this new value will be used when applying correlations between steps `i` and `i+1`.
Taking this approach applies correlations to ``A`` sequentially to propagate nonlinearities
to subsequent steps.
"""
function correlate(v::AbstractArray, A::AbstractMatrix, order::AbstractVector{Int})
    N = size(v,1)
    
    # Save a list of the A1 = A[ii,:] matrix, where each row ii is individually selected and
    # consistent with the natural order. Then, reorder this list to match the permutation order.
    lst_A = pick_from(A; dims=2)
    lst_A = lst_A[order]

    # Apply the interaction defined in each row individually and sequentially.
    # If A is a 3x3 matrix, ordered [2,3,1], this would look like.
    #   v[1] = A[2,:] * v
    #   v[2] = A[3,:] * A[2,:] * v
    #   v[3] = A[1,:] * A[3,,:] * A[2,:] * v
    # Note how the interactions defined in A are applied in the permuted order,
    # but the order in which the VALUES are stored remains unchanged.
    prod_A = [*(lst_A[ii:-1:1]...) for ii in 1:N]
    lst_v = [*(lst_A[ii:-1:1]...) * v for ii in 1:N]
    
    # Now, populate the final, correlated value with the iith ROW (the current investment)
    # of the iith list element (the impact of ALL investments, IN THE PERMUTED ORDER)
    # on ALL values thus far.
    vout = copy.(v)
    [vout[ii,:] .= lst[ii,:] for (ii,lst) in zip(order, lst_v)]
    return update_stop!(convert(Matrix, vout))
end


"""
    correlate!(x::Cascade)
This function applies the correlation matrix defined in `x.correlation` to
the values in `x.steps` using [`correlate`](@ref)

# Returns
- `x::Cascade` with the following updates:
    1. `x.steps`, with correlations applied;
    1. `x.stop`, to the new cumulative sum after correlations have been applied; and
    1. `x.correlation_applied=true`, to avoid the risk of applying the correlation matrix
        multiple times.
"""
function correlate!(cascade::Cascade{Data}; kwargs...)
    if !cascade.iscorrelated
        data = collect_data(cascade)

        v = get_value(data)
        A = collect_correlation(cascade)
        order = collect_permutation(cascade.permutation)

        set_value!(data, correlate(v, A, order))
        cascade.iscorrelated = true
    end

    return cascade
end


"""
"""
function Base.permute!(cascade::Cascade; kwargs...)
    if !cascade.ispermuted
        cascade.steps = cascade.steps[get_permutation(cascade.permutation)]
        cascade.ispermuted = true
    end
    return cascade
end


"""
```jldoctest
julia> pick(3, 4)
4×4 SparseArrays.SparseMatrixCSC{Int64,Int64} with 1 stored entry:
  [3, 3]  =  1

julia> pick(1:2, 4)
4×4 SparseArrays.SparseMatrixCSC{Int64,Int64} with 2 stored entries:
  [1, 1]  =  1
  [2, 2]  =  1
```
"""
pick(idx, dim) = SparseArrays.sparse(fill([idx;],2)..., 1, fill(dim,2)...)
pick(dim) = [pick(ii,dim) for ii in 1:dim]


"""
    pick_from(A; kwargs...)
This method returns a list ``\\vec{A}`` of all correlation factors ``A_i`` calculated using
`pick_from(ii,A; kwargs...)`:

```math
\\vec{A} = \\begin{pmatrix}
A_1 & A_2 & \\dots A_{N}
\\end{pmatrix}
```

    pick_from(ii, A; kwargs)
This function returns the correlation matrix ``A_i`` with all off-diagonal elements,
with the exception of those in ROW or COLUMN `ii`, set to zero.

# Arguments
- `A <: AbstractMatrix`, a random correlation matrix ``A \\in \\mathbb{R}^{N\\times N}``,
    produced by [`random_rotation`]
- `ii::Int`, non-zero ROW OR COLUMN

# Keyword Arguments
- `dims::Int = 1, 2`: Matrix dimension from which to select.

# Returns
- `A_i <: AbstractMatrix`, defined as

```math
\\begin{aligned}
A_{i,\\circ} &= S_i A' + I
\\\\
A_{\\circ,j} &= A' S_j + I
\\end{aligned}
```

where
- ``S_i \\in \\mathbb{Z}^{N\\times N}`` is a sparse matrix produced by [`pick`](@ref)
    with `[i,i]=1`
- ``A' \\in \\mathbb{R}^{N\\times N}`` is defined:

```math
A' = \\begin{cases}
A_{i,j} & i\\neq j \\
0       & i=j
\\end{cases}
```

All diagonal elements of ``A`` are set to zero prior to performing any calculations since
selecting a row using ``S_i`` zeros all other elements on the diagonal. Explicitly adding
``I`` ensures that applying correlations to the `i`th step will not impact any other steps.
"""
function pick_from(ii::Int, A; dims)
    N = size(A,1)
    # Ensure that, if A has ones on the diagonal, these are made zero.
    # When one row is "picked", this will zero the other elements on the diagonal,
    # so we will add these back at each step in the iteration.
    # LinearAlgebra.tr(A)==N && (A -= I)
    A -= I
    
    return (dims==1 ? pick(ii,N)*A : A*pick(ii,N)) + I
end

pick_from(A; kwargs...) = [pick_from(ii,A; kwargs...) for ii in 1:size(A,1)]