using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
# include(joinpath(WATERFALL_DIR,"src","Cascade","Cascade2.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Plot2.jl"))

function cutoff(df::DataFrames.DataFrame; maxsteps=6, value=:Value)
    ii = [1; sortperm(abs.(df[2:end-1,value]); rev=true)[1:maxsteps].+1; size(df,1)]
    return df[ii,:]
end

# sort_by(lst, field) = lst[sortperm(getproperty.(lst,field))]

# function calculate_ordered_mean(lst::Vector{Vector{Data}})
#     # Would be smart to check if they're all the same label first.
#     srt = sort_by.(lst,:label)
#     result = copy(srt[1])

#     # We have an issue with _get if it's a list of lists.
#     # Yeah, just lost of issues with dimensions and whatnot.
#     # Want dims to be the same if we have 1 or more samples.
#     v = cat(get_value.(srt)...; dims=3)
#     vbeg = cat(get_beginning.(srt)...; dims=3)
#     vend = cat(get_ending.(srt)...; dims=3)

#     set_value!(result, Statistics.mean(v; dims=3)[:,:,1])
#     set_beginning!(result, Statistics.mean(vbeg; dims=3)[:,:,1])
#     set_ending!(result, Statistics.mean(vend; dims=3)[:,:,1])

#     return result
# end
maxsteps = 6
df0 = copy(df)

df = cutoff(df; maxsteps=maxsteps)

cascade_corr = Waterfall.Cascade(df; maxrot=0.1, apply_correlation=true, kwargs...)
cascade_uncorr = Waterfall.Cascade(df; maxrot=0.1, apply_correlation=false, kwargs...)

