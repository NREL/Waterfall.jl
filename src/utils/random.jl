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
function random_samples(value, numsample;
    distribution=:uniform,
    fuzziness=FUZZINESS,
    numcorrelated=NUMCORRELATED,
    kwargs...,
)
    dim = length(value)

    dx = _random_uniform(fuzziness..., dim)
    translation = random_translation(distribution, dx, numsample)
    correlation = random_correlation(dim, numcorrelated)

    return correlation * translation .+ value
end


"""
"""
function random_translation(distribution::Symbol, dx::Vector, N; kwargs...)
    return random_translation(fill(distribution,length(dx)), dx, N; kwargs...)
end


function random_translation(distribution::Vector, dx::Vector, N; seed=-1)
    dim = length(dx)
    seed = seed<0 ? make_seed.(dx) : fill(seed,dim)

    if length(distribution)!==length(dx)
        distribution .= distribution[rand(1:length(distribution), dim)]
    end

    lst = [random_translation(d, x, N; seed=s) for (d,x,s) in zip(distribution,dx,seed)]
    return hcat(lst...)'
end


function random_translation(distribution::Symbol, dx::Float64, N::Integer; seed=1234)
    Random.seed!(seed)
    return if distribution==:uniform; _random_uniform(dx, N)
    elseif distribution==:normal;     _random_normal(dx, N)
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
https://cran.r-project.org/web/packages/GauPro/vignettes/IntroductionToGPs.html#:~:text=Gaussian%20correlation,correlation%20function%20is%20the%20Gausian.&text=The%20parameters%20θ%3D(θ1,Gaussian%20process%20model%20to%20data
https://scipy-cookbook.readthedocs.io/items/CorrelatedRandomSamples.html
"""
function random_correlation(dim, args...; kwargs...)
    rot = random_rotation(dim, args...; kwargs...)
    A = rot' * rot
    C = LinearAlgebra.cholesky(A / maximum(abs.(A)))
    return C.L
end


""
function random_rotation(dim::Integer, args...; seed=1234, kwargs...)
    rot = zeros(dim,dim)+I
    idx = random_index(LinearAlgebra.UnitLowerTriangular(rot), args...)
    
    Random.seed!(seed)
    val = [
        _random_uniform(0.0,1.0,Integer(floor(length(idx)/2)));
        _random_uniform(-1.0,0.0,Integer(ceil(length(idx)/2)));
    ]

    for ii in 1:length(idx)
        rot[idx[ii]...] = val[ii]
        rot[reverse(idx[ii])...] = val[ii]
    end

    return rot
end


"This function returns a `numcorrelated`-element Array of random indices from `mat`."
function random_index(mat::LinearAlgebra.UnitLowerTriangular; seed=1, kwargs...)
    idx = list_index(mat)
    idx = idx[getindex.(idx,2) .< getindex.(idx,1)]

    Random.seed!(seed)
    return Random.shuffle(idx)
end

function random_index(mat, numcorrelated::Integer; kwargs...)
    maxrand = Integer((size(mat,1) * (size(mat,1)-1))/2)
    numcorrelated = min(numcorrelated,maxrand)

    return random_index(mat; kwargs...)[1:numcorrelated]
end


"""
This function returns a sorted list of all matrix indices.

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


"This function returns a 4-digit integer equal to the first four significant digits of "
function make_seed(x::Float64, len=4)
    return convert(Integer, round(parse(Float64,
        Printf.@sprintf("%.10e", x)[1:len+1]) * 10^(len-1)))
end