# add method to permute column order (like sample order) -- make 14 histograms of how high the bar was when permuted. if the histogram is only one peak, no correlation.
#   display what correlation is
#   which ordering accentuates correlation for a particular dataset to show someone an ordering that
#   GOAL: "correlation coefficient needs to be 0.8 to see difference in ordering"
# bring two waterfall plots with different orders and show different bar heights

# shuffle columns to show correlation: traditional waterfall
#   average height among all waterfall orderings? if plotting in a particular ordering, have a silouhette of average height.
#       IF plotted height = silouhette, not correlated
#                           < silouhette, something up/
# turn the knob until it's obvious in the parallel coordinates plot.
# add some outliers
# binomial distribution would show two schools of thought -- or sum normals with bimodal distribution


"""
"""
function random_samples(value; kwargs...)
    dim = length(value)
    translation = random_translation(dim; kwargs...)
    # correlation = random_correlation(dim; kwargs...)
    return translation .+ value
end


"""

"""
function random_translation(dim;
    nsample = DEFAULT_NSAMPLE,
    distribution = DEFAULT_DISTRIBUTION,
    fuzziness = DEFAULT_FUZZINESS,
    seed = SEED,
    kwargs...,
)
    Random.seed!(SEED)
    offset = nsample==1 ? fill(0.0,dim) : random_uniform(fuzziness..., dim)
    return _random_translation(nsample, distribution, offset)
end


function _random_translation(N, distribution::Symbol, offset::Vector)
    return _random_translation(N, fill(distribution,length(offset)), offset)
end


function _random_translation(N, distribution::Vector, offset::Vector; seed=SEED)
    # If given multiple distributions to select from, do so at random.
    if length(unique(sort!(distribution)))>1
        Random.seed!(seed)
        distribution .= distribution[rand(1:length(distribution), length(offset))]
    end

    lst = [_random_translation(N, dist, off) for (dist,off) in zip(distribution,offset)]
    return hcat(lst...)'
end


function _random_translation(N, distribution::Symbol, offset::Float64)
    offset!==1.0 && Random.seed!(make_seed(offset))
    return if distribution==:uniform; random_uniform(offset, N)
    elseif distribution==:normal;     random_normal(offset, N)
    else;                             _distribution_error()
    end
end


"""
    random_uniform(x1, x2, N)
    random_uniform(dx, N)
This function returns an `N`-element Array of random values on the interval
`[x1,x2]` or `[-dx,+dx]`
"""
random_uniform(x1::Float64, x2::Float64, N) = rand(Distributions.Uniform(x1, x2), N)
random_uniform(dx::Float64, N) = random_uniform(-dx, dx, N)


"""
    random_normal(var, N)
This function returns an `N`-element Array of random values from a normal distribution
centered at `0` with a variance `var`
"""
random_normal(var::Float64, N) = rand(Distributions.Normal(0, abs(var)), N)


"""
    random_correlation(dim; kwargs...)
    random_correlation(dim, N; kwargs...)
This function returns a scaling matrix ``C \\in \\mathbb{R}^{dim\\times dim}``,
defined such that ``C C^T = R``, where ``R`` is the covariance matrix.

```math
R' = R^T R
\\
C = \\text{Cholesky}(R' / \\max(R'))
```

``R`` is the rotation matrix returned by ``random_rotation``, squared to ensure it is
positive definite, and ``C`` is computed as the lower triangular component of the Cholesky
factorization of ``R'``.

https://cran.r-project.org/web/packages/GauPro/vignettes/IntroductionToGPs.html#:~:text=Gaussian%20correlation,correlation%20function%20is%20the%20Gausian.&text=The%20parameters%20θ%3D(θ1,Gaussian%20process%20model%20to%20data
https://scipy-cookbook.readthedocs.io/items/CorrelatedRandomSamples.html
"""
function random_correlation(dim;
    nrandom = DEFAULT_NCOR,
    method = :eig,
    kwargs...,
)
    rot = random_rotation(dim;
        symmetric=true,
        type=LinearAlgebra.UnitLowerTriangular,
        kwargs...,
    )

    if method==:eig
        eigval = LinearAlgebra.eigvals(rot)
        eigvec = LinearAlgebra.eigvecs(rot)
        cor = eigvec * LinearAlgebra.diagm(sqrt.(eigval))
    else
        cor = LinearAlgebra.cholesky(rot).L
    end

    return cor
end


"""
    random_rotation(dim; kwargs...)
    random_rotation(dim, N; kwargs...)
This function returns a rotation matrix ``R \\in \\mathbb{R}^{dim\\times dim}``,
defined as ``R = I``, with ``2N`` elements filled such that:

```math
R_{i,j} = R_{j,i} = x
,\\;\\text{where}\\;
\\left\\{
    x \\;\\big\\vert\\; |x| \\in \\left[ x_{min},x_{max} \\right],\\, x\\in\\mathbb{R}^{N}
\\right\\}
```

# Keyword Arguments
- `seed=SEED` for random number generator set before picking the values with which to fill
    the rotation matrix.
- `interactivity=(0.0,0.1)` the range of minimum and maximum allowed rotation

# Returns
- `mat::Matrix` rotation matrix

# Example

```jldoctest
julia> random_rotation(4, 3)
4×4 LinearAlgebra.UnitLowerTriangular{Float64,Array{Float64,2}}:
 1.0         ⋅         ⋅    ⋅ 
 0.766797   1.0        ⋅    ⋅ 
 0.590845  -0.433763  1.0   ⋅ 
 0.0        0.0       0.0  1.0
```
"""
function random_rotation(dim::Integer;
    maxdim = missing,
    permutation = missing,
    interactivity = (0.0,0.1),
    nrandom = true,
    seed = SEED,
    type = I,
    kwargs...,
)
    maxdim = coalesce(maxdim, dim)
    permutation = sort(coalesce(permutation, 1:dim))

    rot = matrix(type, maxdim)
    idx = random_index(rot, nrandom)
    N = length(idx)

    # Generate random values.
    Random.seed!(seed)
    val = [
        random_uniform( interactivity..., Integer(ceil(N/2)));
        random_uniform(-reverse(collect(interactivity))..., Integer(floor(N/2)));
    ]

    rot = _fill!(rot, idx.=>val; kwargs...)
    
    # Now, select elements of the rotation matrix that are relevant to the given permutation.
    return rot[permutation, permutation]
end


"""
    _fill!(mat, x; kwargs...)
This is a helper function that fills and returns `mat` with the values listed in
`x = idx => val`.
"""
function _fill!(mat, x::Pair; symmetric=false, kwargs...)
    mat[x[1]...] = x[2]

    if symmetric
        mat = Matrix{}(mat)
        mat[reverse(x[1])...] = x[2]
    end

    return mat
end

function _fill!(mat, lst; kwargs...)
    [mat = _fill!(mat, x; kwargs...) for x in lst]
    return mat
end

_fill!(mat::LinearAlgebra.Diagonal, args...; kwargs...) = _fill!(Matrix{}(mat), args...; kwargs...)


"""
    random_permutation(rng::UnitRange, nperm::Int; kwargs...)
This function returns an `nperm`-element list of unique permutations of `rng`.

# Keyword Arguments
- `seed=SEED`
"""
function random_permutation(rng::UnitRange, nperm::Int; seed=SEED)
    # Ensure the input number of permutations is feasible.
    nperm = min(factorial(last(rng)), nperm)

    Random.seed!(seed)
    idx = StatsBase.sample(1:factorial(rng.stop), nperm; replace=false)
    return [Combinatorics.nthperm(rng, ii) for ii in idx]
end


"""
    random_index(x; kwargs...)
    random_index(x, N; kwargs...)
This function returns a list of random indices for which `x` is defined.

# Arguments
- `x::AbstractArray`: If `x` is a triangular matrix, return only values above/below
    (and on, if `x` is not unitary) the diagonal
- `N::Int`: number of indices to return

# Keyword Arguments
- `seed=SEED` for random number generator

# Returns
- `idx::Vector` of indices

```jldoctest
julia> random_index(lower_triangular(8), 4)
4-element Array{Array{Int64,1},1}:
 [7, 3]
 [5, 1]
 [6, 5]
 [6, 4]
```
"""
random_index(x, N::Bool; kwargs...) = N ? random_index(x; kwargs...) : []

function random_index(x, N::Int; kwargs...)
    idx = random_index(x; kwargs...)
    return idx[1:min(length(idx),N)]
end

random_index(x; kwargs...) = _shuffle(list_index(x); kwargs...)

random_index(D::LinearAlgebra.Diagonal; kwargs...) = _random_index(D, !=; kwargs...)
random_index(L::LinearAlgebra.UnitLowerTriangular; kwargs...) = _random_index(L, <; kwargs...)
random_index(U::LinearAlgebra.UnitUpperTriangular; kwargs...) = _random_index(U, >; kwargs...)
# random_index(L::LinearAlgebra.LowerTriangular; kwargs...) = _random_index(L, <=; kwargs...)
# random_index(U::LinearAlgebra.UpperTriangular; kwargs...) = _random_index(U, >=; kwargs...)


"""
This is a helper function to apply `random_index` to a matrix with a constraint
on its index (ex: triangular)
"""
function _random_index(mat, constraint; kwargs...)
    idx = _constrain_index(list_index(mat), constraint)
    return _shuffle(idx; kwargs...)
end

"This is a helper function to apply a constraint to a list of matrix indices.
At the moment, it only works for ``2\\times 2`` matrices."
function _constrain_index(idx::Vector{Vector{Int}}, fun)
    return idx[broadcast(fun, getindex.(idx,2), getindex.(idx,1))]
end

"This is a helper function to set a seed and shuffle the index in one step."
function _shuffle(idx; seed=SEED, kwargs...)
    Random.seed!(seed)
    return Random.shuffle(idx)
end


"""
    list_index(x::T) where T<:AbstractArray
This function returns a sorted list of all vector or matrix indices.

```jldoctest
julia> list_index(lower_triangular(3))
9-element Array{Array{Int64,1},1}:
 [1, 1]
 [1, 2]
 [1, 3]
 [2, 1]
 [2, 2]
 [2, 3]
 [3, 1]
 [3, 2]
 [3, 3]
```
"""
list_index(mat::T) where T<:AbstractMatrix = sort(permute(UnitRange.(1, size(mat))...))
list_index(vec::T) where T<:AbstractVector = collect(1:length(vec))


"This function returns a `len`-digit integer equal to the first four significant digits of `x`"
function make_seed(x::Float64, len=4)
    return convert(Integer, round(parse(Float64,
        Printf.@sprintf("%.10e", x)[1:len+1]) * 10^(len-1)))
end