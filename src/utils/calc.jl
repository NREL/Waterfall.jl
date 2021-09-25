using Base

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
dropzero(mat::Matrix) = mat[all.(eachrow(abs.(mat).>=1E-10)),:]
dropzero(vec::Vector) = vec[abs.(vec).>=1E-10]


"""
This function calculates the graphical width of each bar based on the number of cascade
steps, ``N_{step}``:
```math
w_{step} = \\dfrac{WIDTH - \\left(N_{step}+1\\right) SEP}{N_{step}}
```
"""
width(steps::Integer; space=SEP, margin=SEP/2) = (WIDTH - 2*margin - space*steps)/steps


"""
"""
function cumulative_v(v::AbstractArray; shift=0.0, kwargs...)
    N = size(v,1)
    L = matrix(LinearAlgebra.UnitLowerTriangular, N; value=1.0) + shift*I
    return L * v
end

cumulative_v(x::Cascade{Data}; kwargs...) = cumulative_v(collect_value(x); kwargs...)


"""
"""
# function subtractive(lst::Vector{Matrix{T}}) where T<:Real
#     # v1 = 
# end


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
    # vout = copy.(v)
    # [vout[ii,:] .= lst[ii,:] for (ii,lst) in zip(order, lst_v)]
    # return update_stop!(convert(Matrix, vout))
    update_stop!(collect_value(lst_v, order))
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