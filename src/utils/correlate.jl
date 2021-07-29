"""
This function returns a list of cumulative correlation products:

```math
lst =
\\begin{bmatrix}
        \\left(S_{i_1} A' + I\\right)
\\\\ \\left(S_{i_2} A' + I\\right) \\left(S_{i_1} A' + I\\right)
\\\\ \\vdots
\\\\ \\left(S_{i_N} A' + I\\right) \\dots
        \\left(S_{i_2} A' + I\\right) \\left(S_{i_1} A' + I\\right)
\\end{bmatrix}
```
"""
function rowprod(A::M, order::Vector{T}) where {M<:AbstractMatrix, T<:Int}
    lst = select_row(A)

    idxprod = [[order[1]]]
    lstprod = [lst[order[1]]]

    for ii in order[2:end]
        push!(idxprod, [ii; idxprod[end]])
        push!(lstprod, lst[ii]  * lstprod[end])
    end

    return lstprod
end


function rowprod(lst::Vector{M}, v::Matrix{T}) where {M<:AbstractMatrix, T<:Real}
    # v is NOT re-ordered.
    return [update_stop!(A * v) for A in lst]
end


function rowprod(x::Cascade)
    A = collect_correlation(x)
    v = get_value(collect_data(x))
    perm = collect_permutation(x)
    
    lst = rowprod(A, perm)
    return rowprod(lst, v)
end


function rowprod!(x::Cascade, idx=missing)
    data = collect_data(x)
    ismissing(idx) && (idx=length(data))
    set_value!(data, rowprod(x)[idx])
    return x
end


"""
    select_row(A)
This method returns a list ``\\vec{A}`` of all correlation factors ``A_i`` calculated using
`select_row(A,ii)`:

```math
\\vec{A} = \\begin{pmatrix}
A_1 & A_2 & \\dots A_{N}
\\end{pmatrix}
```

    select_row(A, ii)
This function returns the correlation matrix ``A_i`` with all off-diagonal elements,
with the exception of those in row `ii`, set to zero.

# Arguments
- `A <: AbstractMatrix`, a random correlation matrix ``A \\in \\mathbb{R}^{N\\times N}``,
    produced by [`random_rotation`]
- `ii::Int`, non-zero row

# Returns
- `A_i <: AbstractMatrix`, defined as

```math
A_i = S_i A' + I
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
function select_row(A, ii)
    N = size(A,1)
    # Ensure that, if A has ones on the diagonal, these are made zero.
    # When one row is "picked", this will zero the other elements on the diagonal,
    # so we will add these back at each step in the iteration.
    LinearAlgebra.tr(A)==N && (A -= I)

    return pick(ii,N) * A + I
end

select_row(A) = [select_row(A,ii) for ii in 1:size(A,1)]