"""
    fuzzify(df::DataFrames.DataFrame; kwargs...)
This function adds "fuzziness" to an input `df`

# Keyword Arguments
- value::Symbol=:Value
- samples::Integer=50
- distribution::Symbol=:normal
- factor
"""
function fuzzify(df; value::Symbol=:Value, samples::Integer=SAMPLES,
    distribution=:normal,
    fuzziness=(0.01,0.15),
    kwargs...,
)
    println("\n\nInjecting fuzziness into input DataFrames.DataFrame over $samples samples.")
    idx = DataFrames.Not([value,SAMPLE])
    distribution = [distribution;]

    # (1) Add step-wise information.
    if samples==1
        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE => 1:samples))
    else
        Random.seed!(1234)
        steps = size(df,1)
        df[!,:fuzziness] .= _fuzzify_uniform(fuzziness, steps)
        df[!,:distribution] .= distribution[rand(1:length(distribution), steps)]
        # tmp = _fuzzify(df[:,:distribution], df[:,value], df[:,:fuzziness], samples)
        tmp = _correlated_fuzzify(df[:,value], df[:,:fuzziness], samples)

        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE=>1:samples))
        df[!,value] .= tmp
    end
    
    # (2) Re-calculate the final row to equal the cumulative sum of all preceeding steps.
    gdf = DataFrames.groupby(df, idx)
    rng = UnitRange.(gdf.starts[end-1:end],gdf.ends[end-1:end])
    df[rng[2],value] .= -DataFrames.transform(
        DataFrames.groupby(df, :Sample), value => (x -> cumsum(x)) => value)[rng[1],value]
    return DataFrames.groupby(df, idx)
end


""
function make_seed(x::Float64)
    return convert(Integer, round(parse(Float64, Printf.@sprintf("%.3e", x)[1:5]) * 10^3))
end


""
function _correlated_fuzzify(fuzziness, N; seed=1234)
    Random.seed!(seed)
    return rand(Distributions.Normal(0, abs(fuzziness)), N)
end

function _correlated_fuzzify(mu, fuzziness, N; seed=-1)
    steps = length(mu)
    seed = seed<0 ? make_seed.(fuzziness) : fill(seed,length(mu))
    randomness = hcat([_correlated_fuzzify(f, N; seed=s) for (f,s) in zip(fuzziness,seed)]...)'

    # https://scipy-cookbook.readthedocs.io/items/CorrelatedRandomSamples.html
    # https://discourse.julialang.org/t/generate-random-positive-definite-symmetric-matrix/53816
    X = randn(steps,steps)
    A = X' * X
    C = LinearAlgebra.cholesky(A / maximum(A))

    result = C.L * randomness
    result = result .+ mu
    return vcat([result[ii,:] for ii in 1:steps]...)
end


""
function _fuzzify(fun::Function, μ::Real, fuzziness::Real, N::Integer; seed=1234)
    Random.seed!(seed)
    return fun(μ, fuzziness, N)
end

function _fuzzify(distribution::Symbol, μ::Real, fuzziness::Real, N::Integer; kwargs...)
    return _fuzzify(_fuzzify_function(distribution), μ, fuzziness, N; kwargs...)
end

function _fuzzify(
    distribution::AbstractArray,
    μ::AbstractArray,
    fuzziness::AbstractArray,
    N::Integer;
    seed::Integer=-1,
    kwargs...,
)
    seed = seed<0 ? make_seed.(fuzziness) : fill(seed,length(fuzziness))
    return vcat([_fuzzify(d,x,f,N; seed=s, kwargs...)
        for (d,x,f,s) in zip(distribution, μ, fuzziness, seed)]...,)
end


"This function returns the function to use given an identifying symbol."
function _fuzzify_function(distribution::Symbol)
    fun = if distribution==:normal; _fuzzify_normal
    elseif distribution==:uniform;  _fuzzify_uniform
    else;                           _distribution_error()
    end
end


""
_fuzzify_normal(μ::Real, var::Real, N) = rand(Distributions.Normal(μ, abs(var)), N)
_fuzzify_normal(args...) = _fuzzify(_fuzzify_normal, args...)
    
""
_fuzzify_uniform(x::Tuple{T,T}, N) where T<:Real = rand(Distributions.Uniform(x[1], x[2]), N)
_fuzzify_uniform(μ::Real, dμ::Real, N) = _fuzzify_uniform((μ-dμ,μ+dμ), N)
# _fuzzify_uniform(μ::Real, f::Real, N) = μ * _fuzzify_uniform((1-f,1+f), N)
_fuzzify_uniform(args...) = _fuzzify(_fuzzify_uniform, args...)


"""
"""
_distribution_error(args...) =  _option_error("distribution", [:normal,:uniform], args...)


""
function _option_error(option, allowed::String)
    throw(ArgumentError("Allowed values for $option: $allowed"))
end

function _option_error(option, allowed::AbstractArray)
    return _option_error(option, string((string.(allowed).*", ")...,)[1:end-2])
end

function _option_error(option, allowed, value)
    return if isempty(value)
        _option_error(option, allowed)
    else
        throw(ArgumentError("$option = $value. Allowed values: $allowed"))
    end
end