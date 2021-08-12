# ***** KEEP *****
# The paper begins with an example in which swapping the first two (plotted) steps makes a
# high impact on the values of these two steps. In this file, we examine the impact of
# plotting ONLY the first two steps -- which could be any two of N total steps.
using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

localkwargs = (
    nsample = 1000,
    ncor = true,
    correlate = true,
    permute = true,
)

function idk(df, swaps; kwargs...)
    cascades = Dict(swap => define_from(Cascade{Data}, df; permutation=swap, kwargs...)
        for swap in swaps)
    return Dict(swap => get_value(collect_data(cascade)) for (swap,cascade) in cascades)
end
    
# Find all combinations of four steps AND swap the first two elements.
N = size(df,1)-2
xsrt = collect(Combinatorics.combinations(1:N,4))
xrev = swapat!.(copy.(xsrt),1,2)

vsrt = idk(df, xsrt; localkwargs..., kwargs...)
vrev = idk(df, xrev; localkwargs..., kwargs...)


# Summarize in DataFrame. What's the greatest difference in MEAN FINAL VALUE between [1,2]
dfsrt = DataFrames.DataFrame(srt=xsrt, rev=xrev, vsrt_2=0.0, vsrt_3=0.0, vsrt_end=0.0)
[dfsrt[ii,:vsrt_2] = Statistics.mean(vsrt[dfsrt[ii,:srt]][2,:]) for ii in 1:size(dfsrt,1)]
[dfsrt[ii,:vsrt_3] = Statistics.mean(vsrt[dfsrt[ii,:srt]][3,:]) for ii in 1:size(dfsrt,1)]
[dfsrt[ii,:vsrt_end] = Statistics.mean(vsrt[dfsrt[ii,:srt]][end,:]) for ii in 1:size(dfsrt,1)]

dfrev = DataFrames.DataFrame(rev=xrev, vrev_2=0.0, vrev_3=0.0, vrev_end=0.0)
[dfrev[ii,:vrev_2] = Statistics.mean(vrev[dfrev[ii,:rev]][2,:]) for ii in 1:size(dfrev,1)]
[dfrev[ii,:vrev_3] = Statistics.mean(vrev[dfrev[ii,:rev]][3,:]) for ii in 1:size(dfrev,1)]
[dfrev[ii,:vrev_end] = Statistics.mean(vrev[dfrev[ii,:rev]][end,:]) for ii in 1:size(dfrev,1)]


dfsum = DataFrames.innerjoin(dfsrt, dfrev, on=:rev)
dfsum[!,:diff_2] .= abs.(dfsum[:,:vsrt_2] .- dfsum[:,:vrev_2])
dfsum[!,:diff_3] .= abs.(dfsum[:,:vsrt_3] .- dfsum[:,:vrev_3])
dfsum[!,:diff_end] .= abs.(dfsum[:,:vsrt_end] .- dfsum[:,:vrev_end])


dfsum[!,:comp] .= dfsum[:,:diff_2] .* dfsum[:,:diff_3] .* dfsum[:,:diff_end]
DataFrames.select!(dfsum, [:srt,:rev,:comp,:diff_2,:diff_3,:diff_end])



# ii = collect(1:N)
# swaps = collect(Combinatorics.combinations(1:N,2))
# swaps = swaps[getindex.(swaps,1).==1]

# perms = Dict(swap => swapat!(collect(1:N), swap...) for swap in swaps)

# nsample = 1000

# v = Dict(swap => update_stop!(get_value(collect_data(
#     define_from(Cascade{Data}, df[[1:N+1;size(df,1)],:];
#         nsample=nsample,
#         ncor=false,
#         correlate=false,
#         permute=true,
#         permutation=perms[swap],
#         kwargs...,
#         interactivity=(0.1,0.2),
#     )))) for swap in swaps)

# # Summary DataFrame of all of the pairwise swaps that could be made.
# N = length(swaps)
# df = DataFrames.DataFrame(swap=swaps,)
# df[!,:cumulative] .= [cumulative_v(v[df[ii,:swap]]) for ii in 1:N]
# df[!,:max] .= [Statistics.maximum(df[ii,:cumulative][2:end-1,1]) for ii in 1:N]
# df[!,:min] .= [Statistics.minimum(df[ii,:cumulative][2:end-1,1]) for ii in 1:N]
# df[!,:diff] .= df[:,:max] .- df[:,:min]

# df[!,:endmax] .= [Statistics.maximum(df[ii,:cumulative][end-2:end-1,:]) for ii in 1:N]
# df[!,:endmin] .= [Statistics.minimum(df[ii,:cumulative][end-2:end-1,:]) for ii in 1:N]
# df[!,:enddiff] .= df[:,:endmax] .- df[:,:endmin]





# # 
# # swaps = collect(Combinatorics.combinations(1:N,2))