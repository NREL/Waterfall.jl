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
ncor = 3

df = cutoff(df; nstep=nstep)

cascade = Waterfall.Cascade(df; minrot=0.5,  maxrot=0.7, apply_correlation=true, nsample=nsample, ncor=ncor, kwargs...)
cascade0 = Waterfall.Cascade(df; minrot=0.5, maxrot=0.7, apply_correlation=false, nsample=nsample, ncor=ncor, kwargs...)

# Convert cascade
# plot_cascade(cascade)
v = Waterfall.get_value(Waterfall.collect_data(cascade0))
A = Waterfall.collect_correlation(cascade0)

idx = Waterfall.random_index(1:N)

lst0 = correlation_factor(A)
lst = correlation_cumprod(A, idx)