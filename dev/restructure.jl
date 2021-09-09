# https://discourse.julialang.org/t/generate-random-value-from-a-given-function-out-of-box/5793/3
using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))


function define_permute(df, nperm::T; kwargs...) where T<:Integer
    N = size(df,1)-2
    lst = [[collect(1:N)]; random_permutation(1:N, min(factorial(N),nperm))]
    return define_permute(df, lst; kwargs...)
end

function define_permute(df::DataFrames.DataFrame, lst::T; fun::Function=identity, kwargs...) where T<:AbstractArray
    cascades = Dict()
    heights = Dict()

    for k in lst
        cascade = define_from(Cascade{Data}, df;
            permutation=k,
            nsample=100,
            correlate=true,
            permute=false,
            ncor=true,
            kwargs...,
        )
        push!(cascades, k => cascade)

        v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
        v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
        push!(heights, k => v2.-v1)
    end

    # Make dictionary of heights into one cascade.
    cascade = copy(cascades[first(lst)])
    data = collect_data(cascade)

    median = cat([collect_value(calculate(cascades[k], Statistics.quantile, 0.5)) for k in lst]...; dims=2)

    set_value!.(data, vectorize(median))
    return cascade
end