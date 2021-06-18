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
function correlation_cumprod(A::M, idx) where M<:AbstractMatrix
    lst = correlation_factor(A)

    idxprod = [[idx[1]]]
    lstprod = [lst[idx[1]]]

    for ii in idx[2:end]
        push!(idxprod, [ii; idxprod[end]])
        push!(lstprod, lst[ii]  * lstprod[end])
    end

    return lstprod
end


"""
    correlation_factor(A)
This method returns a list ``\\vec{A}`` of all correlation factors ``A_i`` calculated using
`correlation_factor(A,ii)`:

```math
\\vec{A} = \\begin{pmatrix}
A_1 & A_2 & \\dots A_{N}
\\end{pmatrix}
```

    correlation_factor(A, ii)
This function returns the correlation matrix ``A_i`` with all off-diagonal elements,
with the exception of those in row `ii`, set to zero.

# Arguments
- `A <: AbstractMatrix`, a random correlation matrix ``A \\in \\mathbb{R}^{N\\times N}``,
    produced by [`Waterfall.random_rotation`]
- `ii::Int`, non-zero row

# Returns
- `A_i <: AbstractMatrix`, defined as

```math
A_i = S_i A' + I
```

where
- ``S_i \\in \\mathbb{Z}^{N\\times N}`` is a sparse matrix produced by [`Waterfall.pick`](@ref)
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
function correlation_factor(A, ii)
    N = size(A,1)
    # Ensure that, if A has ones on the diagonal, these are made zero.
    # When one row is "picked", this will zero the other elements on the diagonal,
    # so we will add these back at each step in the iteration.
    LinearAlgebra.tr(A)==N && (A -= I)

    return Waterfall.pick(ii,N) * A + I
end

correlation_factor(A) = [correlation_factor(A,ii) for ii in 1:size(A,1)]