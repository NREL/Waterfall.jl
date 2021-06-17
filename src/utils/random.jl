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
    # return correlation * translation .+ value
    return translation .+ value
end


"""
"""
function random_translation(dim;
    nsample=DEFAULT_NSAMPLE,
    distribution=DEFAULT_DISTRIBUTION,
    fuzziness=DEFAULT_FUZZINESS,
    seed=1234,
    kwargs...,
)
    Random.seed!(seed)
    offset = nsample==1 ? fill(0.0,dim) : _random_uniform(fuzziness..., dim)
    return _random_translation(nsample, distribution, offset)
end


function _random_translation(N, distribution::Symbol, offset::Vector)
    return _random_translation(N, fill(distribution,length(offset)), offset)
end


function _random_translation(N, distribution::Vector, offset::Vector; seed=1234)
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
    return if distribution==:uniform; _random_uniform(offset, N)
    elseif distribution==:normal;     _random_normal(offset, N)
    else;                             _distribution_error()
    end
end


"""
    _random_uniform(x1, x2, N)
    _random_uniform(dx, N)
This function returns an `N`-element Array of random values on the interval
`[x1,x2]` or `[-dx,+dx]`
"""
_random_uniform(x1::Float64, x2::Float64, N) = rand(Distributions.Uniform(x1, x2), N)
_random_uniform(dx::Float64, N) = _random_uniform(-dx, dx, N)


"""
    _random_normal(var, N)
This function returns an `N`-element Array of random values from a normal distribution
centered at `0` with a variance `var`
"""
_random_normal(var::Float64, N) = rand(Distributions.Normal(0, abs(var)), N)


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
    ncor=DEFAULT_NCOR,
    method=:eig,
    kwargs...,
)
    rot = random_rotation(dim, ncor; kwargs...)

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

# Keyword arguments
- `seed=1234` for random number generator set before picking the values with which to fill
    the rotation matrix.
- `minrot=0.0` minimum rotation ``x_{min}``
- `maxrot=1.0` maximum rotation ``x_{max}``

# Returns
- `mat::Matrix` rotation matrix 
"""
function random_rotation(dim::Integer, args...; seed=1234, minrot=0.0, maxrot=1.0, kwargs...)
    # Select indices overwhich to apply the rotation.
    rot = lower_triangular(dim, 0.)
    idx = random_index(rot, args...)
    N = length(idx)

    # Generate random values.
    Random.seed!(seed)
    val = [
        _random_uniform( minrot,  maxrot, Integer(ceil(N/2)));
        _random_uniform(-maxrot, -minrot, Integer(floor(N/2)));
    ]

    return _fill!(rot, idx.=>val; kwargs...)
end

# random_rotation(dim; ncor)


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


"""
    random_index(x; kwargs...)
    random_index(x, N; kwargs...)
This function returns a list of random indices for which `x` is defined.

# Arguments
- `x::AbstractArray`: If `x` is a triangular matrix, return only values above/below
    (and on, if `x` is not unitary) the diagonal
- `N::Int`: number of indices to return

# Keyword arguments
- `seed=1234` for random number generator

# Returns
- `idx::Vector` of indices

```jldoctest
julia> random_index(lower_triangular(8), 4)
4-element Array{Array{Int64,1},1}:
 [5, 3]
 [2, 1]
 [8, 3]
 [4, 3]
```
"""
function random_index(x, N::Int; kwargs...)
    idx = random_index(x; kwargs...)
    return idx[1:min(length(idx),N)]
end

random_index(x; kwargs...) = _shuffle(list_index(x); kwargs...)

random_index(L::LinearAlgebra.UnitLowerTriangular; kwargs...) = _random_index(L, <; kwargs...)
random_index(U::LinearAlgebra.UnitUpperTriangular; kwargs...) = _random_index(U, >; kwargs...)
random_index(L::LinearAlgebra.LowerTriangular; kwargs...) = _random_index(L, <=; kwargs...)
random_index(U::LinearAlgebra.UpperTriangular; kwargs...) = _random_index(U, >=; kwargs...)


"This is a helper function to apply `random_index` to a matrix with a constraint
on its index (ex: triangular)"
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
function _shuffle(idx; seed=1234, kwargs...)
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


"This function returns a 4-digit integer equal to the first four significant digits of "
function make_seed(x::Float64, len=4)
    return convert(Integer, round(parse(Float64,
        Printf.@sprintf("%.10e", x)[1:len+1]) * 10^(len-1)))
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