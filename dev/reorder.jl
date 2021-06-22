using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","correlate.jl"))

function cutoff(df::DataFrames.DataFrame; nstep=6, value=:Value)
    ii = [1; sortperm(abs.(df[2:end-1,value]); rev=true)[1:nstep].+1; size(df,1)]
    return df[ii,:]
end

function plot_cascade(cascade)
    df = convert(DataFrames.DataFrame, cascade)
    iis = collect(2:nstep+1)

    StatsPlots.gr(size=(1000,1000))
    StatsPlots.@df df StatsPlots.corrplot(cols(iis),
        # grid=false,
        compact=true,
        label =["$(i-1)" for i=iis],
    )
end

nstep = 3
nsample = 2
nperm = 10
ncor = 3

df = cutoff(df; nstep=nstep)

# cascade = Waterfall.Cascade(df; minrot=0.5,  maxrot=0.7, apply_correlation=true, nsample=nsample, ncor=ncor, kwargs...)
x = Waterfall.Cascade(df; minrot=0.05, maxrot=0.15, nsample=nsample, ncor=ncor, kwargs...)

v = Waterfall.get_value(Waterfall.collect_data(x))
A = Waterfall.collect_correlation(x)
N = length(x.steps)

# Convert cascade
plot_cascade(cascade)
# v = Waterfall.get_value(Waterfall.collect_data(cascade0))
# A = Waterfall.collect_correlation(cascade0)
# N = size(A,2)

# lst0 = correlation_factor(A)

perm = [[collect(1:N)]; Waterfall.random_permutation(1:N, min(factorial(N),nperm))]
# perm = [ for x in perm]

# Apply one-at-a-time to observe effects of order.
function correlation_apply(v, lst)
    return [Waterfall.update_stop!(mat * v) for mat in lst]
end

dA = Dict(idx => correlation_cumprod(A, [1; idx.+1; N+2]) for idx in perm)
dv = Dict(idx => correlation_apply(v, lst) for (idx,lst) in dA)

dvprev = Dict(idx => [v[ii][ii+1,:] for ii in 1:N] for (idx,v) in dv)
dvcurr = Dict(idx => [v[ii+1][ii+1,:] for ii in 1:N] for (idx,v) in dv)

# Get values at some step, ii.
ii = 2
getindex.(values(dvcurr),ii)