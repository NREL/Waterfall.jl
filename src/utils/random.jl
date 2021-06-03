# X = random_rotation(steps, 3)
#     # println(X)
    # A = X' * X
    # C = LinearAlgebra.cholesky(A / maximum(A))



using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
df[!,:Units] .= "Efficiency (%)"

# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.3)
numdof=2

kwargs = (distribution=distribution, fuzziness=fuzziness, numdof=numdof)



function fuzzify(df;
    value=:Value,
    numsample=3,
    kwargs...,
)
    idx = DataFrames.Not([value,SAMPLE])

    if samples==1
        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE => 1:samples))
    else
        val = df[:,value]
        val = random_samples(val, numsample; kwargs...)
        val[end,:] .= Statistics.cumsum(val; dims=1)[end-1,:]

        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE=>1:numsample))
        df[!,value] .= vcat(val'...)
    end

    return DataFrames.groupby(df, idx)
end


function random_samples(value, numsample;
    distribution=DISTRIBUTION,
    fuzziness=FUZZINESS,
    numdof=2,
    kwargs...,
)
    dim = length(value)

    dx = _random_uniform(fuzziness..., dim)
    translation = random_translation(distribution, dx, numsample)
    correlation = random_correlation(dim, numdof)

    return correlation * translation .+ value
end



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
    end
end


"This function returns an `N`-element Array of random numsample
on the interval `[x1,x2]` or `[-dx,+dx]`"
_random_uniform(x1::Float64, x2::Float64, N) = rand(Distributions.Uniform(x1, x2), N)
_random_uniform(dx::Float64, N) = _random_uniform(-dx, dx, N)


"This function returns an `N`-element Array of random numsample from a normal distribution
centered at 0 with a variance `var`"
_random_normal(var::Float64, N) = rand(Distributions.Normal(0, abs(var)), N)


"""
"""
function random_correlation(dim, args...; kwargs...)
    rot = random_rotation(dim, args...; kwargs...)
    A = rot' * rot
    C = LinearAlgebra.cholesky(A / maximum(A))
    return C.L
end


""
function random_rotation(dim::Integer, args...; seed=1234, kwargs...)
    rot = zeros(dim,dim)+I
    idx = random_index(LinearAlgebra.UnitLowerTriangular(rot), args...)

    Random.seed!(seed)
    val = rand(length(idx))

    for ii in 1:length(idx)
        rot[idx[ii]...] = val[ii]
        rot[reverse(idx[ii])...] = val[ii]
    end

    return rot
end


"This function returns a `numdof`-element Array of random indices from `mat`."
function random_index(mat::LinearAlgebra.UnitLowerTriangular; seed=1, kwargs...)
    idx = list_index(mat)
    idx = idx[getindex.(idx,2) .< getindex.(idx,1)]

    Random.seed!(seed)
    return Random.shuffle(idx)
end

function random_index(mat, numdof::Integer; kwargs...)
    maxrand = Integer((size(mat,1) * (size(mat,1)-1))/2)
    numdof = min(numdof,maxrand)

    return random_index(mat; kwargs...)[1:numdof]
end


"This function returns a list of all matrix indices"
list_index(mat::T) where T<:AbstractMatrix = list_index(UnitRange.(1, size(mat))...)
list_index(x...) = vec(collect(collect.(Iterators.product(x...))))


"This function returns a 4-digit integer equal to the first four significant digits of "
function make_seed(x::Float64, len=4)
    return convert(Integer, round(parse(Float64, Printf.@sprintf("%.10e", x)[1:len+1]) * 10^(len-1)))
end