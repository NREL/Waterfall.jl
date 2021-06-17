"""
"""
mutable struct Cascade{T<:Sampling}
    start::T
    stop::T
    steps::Vector{T}
    ncor::Int
    permutation::Vector
    correlation::AbstractMatrix
    correlation_applied::Bool
end


# """
#     Cascade( ; kwargs...)
# This method allows for field order-independent Cascade-definition.

# # Keyword arguments
# - `permutation=missing`: Unless otherwise defined, defaults to ordering steps in the order given.


#     Cascade(df::DataFrames.DataFrame; kwargs...)

# # Arguments
# - `df::DataFrames.DataFrame` of input data

# # Keyword arguments
# - `label::Symbol`: `df` column to use to label information
# - See `Waterfall.fuzzify` and `Waterfall.Data`

# # Returns
# - `Cascade{Data}`
# """
function Cascade( ; start, stop, steps, ncor, correlation=[], permutation=[],
    apply_correlation=true,
    correlation_applied=false,
    kwargs...,
)
    # Define and apply correlation.
    if isempty(correlation)
        correlation = random_rotation(length(steps), ncor; kwargs...)
    end

    # Define permutation. !!!! Do so such that non-linear terms are ordered sequentially.
    isempty(permutation) && (permutation = collect(1:length(steps)))

    # Define cascade and apply correlation.
    x = Cascade(start, stop, steps, ncor, permutation, correlation, correlation_applied)
    return apply_correlation ? correlate!(x) : x
end


function Cascade(df::DataFrames.DataFrame; kwargs...)
    gdf = fuzzify(df; kwargs...)

    start = Data(first(gdf); kwargs...)
    stop = Data(last(gdf); kwargs...)
    steps = [Data(gdf[ii]; kwargs...) for ii in 2:gdf.ngroups-1]

    # Sort "start" samples by magnitude. Ensure consistent ordering in all subsequent steps.
    data = [start; steps; stop]
    iiorder = sortperm(get_value(data[1]))
    [set_order!(data[ii], iiorder) for ii in 1:length(data)]
    
    return Cascade( ; start=start, stop=stop, steps=steps, kwargs...)
end


"""
    collect_data(x::Cascade)
This function returns a list of all [`Waterfall.Data`](@ref) Types stored in `x`,
ordered [`x.start; x.steps, x.stop]`.
"""
collect_data(x::Cascade) = Vector{Data}([x.start; x.steps; x.stop])


"""
    collect_correlation(x::Cascade)
This function extends the correlation matrix ``A \\in \\mathbb{R}^{N,N}`` stored in
`x.correlation` by defining ``A' \\in \\mathbb{R}^{N+2,N+2}`` to account for
`x.start` and `x.stop` for consistent dimensionality with the vector returned by
[`Waterfall.collect_data`](@ref).

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
function collect_correlation(x::Cascade)
    mat = x.correlation
    N = size(mat,1)

    L = lower_triangular(N+2, 0.)
    L[2:N+1, 2:N+1] .= mat
    return L
end


get_start(x::Cascade) = x.start
get_steps(x::Cascade) = x.steps
get_stop(x::Cascade) = x.stop


set_start!(x::Cascade, start) = begin x.start = start; return x end
set_steps!(x::Cascade, steps) = begin x.steps = steps; return x end
set_stop!(x::Cascade, stop) = begin x.stop = stop; return x end


"""
This function updates `cascade.stop` or the last row of a matrix to equal the negative
of the cumulative sum of all previous values.
"""
function update_stop!(x::Cascade)
    val = get_value(collect_data(x))
    set_value!(x.stop, update_stop!(val)[end,:])
    return x
end

function update_stop!(x)
    x[end,:] .= -Statistics.cumsum(x; dims=1)[end-1,:]
    return x
end


"""
    correlate(v::AbstractVector, A::AbstractMatrix)
This function applies a correlation matrix `A` to the vector `v`.

```math
\\begin{aligned}
A_{i,i} &= 0
\\\\
\\vec{x} &= \\prod_{i=1}^N \\left(S_{i,i} A+I\\right) \\vec{x}
\\end{aligned}
```

where ``S_{i,i}``, defined using [`Waterfall.pick`](@ref), is a sparse matrix `[i,i]=1`,
``A`` is a random rotation matrix produced by [`Waterfall.random_rotation`](@ref).
``S_{i,i} A`` selects the ``i^\text{th}`` row of ``A``, which defines how steps `1:i-1`
impact step `i`. Once correlations have been applied to the `i`th step,
this new value will be used when applying correlations between steps `i` and `i+1`.
Taking this approach applies correlations to ``A`` sequentially to propagate nonlinearities
to subsequent steps.

All diagonal elements of ``A`` are set to zero prior to performing any calculations since
selecting a row using ``S_{i,i}`` zeros all other elements on the diagonal. Explicitly
adding ``I`` ensures that applying correlations to the `i`th step will not impact any other
steps.
"""
function correlate(v::T, A::M) where {T<:AbstractArray, M<:AbstractMatrix}
    N = size(v,1)
    # Ensure that, if A has ones on the diagonal, these are made zero.
    # When one row is "picked", this will zero the other elements on the diagonal,
    # so we will add these back at each step in the iteration.
    LinearAlgebra.tr(A)==N && (A -= I)

    [v = (pick(ii,N)*A + I) * v for ii in 1:N]
    return v
end


"""
    correlate!(x::Cascade)
This function applies the correlation matrix defined in `x.correlation` to
the values in `x.steps` using [`Waterfall.correlate`](@ref)

# Returns
- `x::Cascade` with the following updates:
    1. `x.steps`, with correlations applied;
    1. `x.stop`, to the new cumulative sum after correlations have been applied; and
    1. `x.correlation_applied=true`, to avoid the risk of applying the correlation matrix
        multiple times.
"""
function correlate!(x::Cascade)
    if !x.correlation_applied
        v = get_value(collect_data(x))
        A = collect_correlation(x)

        v = correlate(v, A)

        set_value!(x.steps, v[2:end-1,:])
        update_stop!(x)

        x.correlation_applied = true
    end
    return x
end


# Base.copy(x::Cascade) = Cascade(copy(x.start), copy(x.stop), copy.(x.steps), copy.(x.order), )

# function Base.convert(::Type{Cascade{T}}, cascade::Cascade{Data}) where T <: Geometry
#     result = T(collect_data(cascade))
#     return Cascade(first(result), last(result), result[2:end-1], cascade.order)
# end