using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Cascade2.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Plot2.jl"))

function cutoff(df::DataFrames.DataFrame; maxsteps=6, value=:Value)
    ii = [1; sortperm(abs.(df[2:end-1,value]); rev=true)[1:maxsteps].+1; size(df,1)]
    return df[ii,:]
end

sort_by(lst, field) = lst[sortperm(getproperty.(lst,field))]

function calculate_ordered_mean(lst::Vector{Vector{Data}})
    # Would be smart to check if they're all the same label first.
    srt = sort_by.(lst,:label)
    result = copy(srt[1])

    # We have an issue with _get if it's a list of lists.
    # Yeah, just lost of issues with dimensions and whatnot.
    # Want dims to be the same if we have 1 or more samples.
    v = cat(get_value.(srt)...; dims=3)
    vbeg = cat(get_beginning.(srt)...; dims=3)
    vend = cat(get_ending.(srt)...; dims=3)

    set_value!(result, Statistics.mean(v; dims=3)[:,:,1])
    set_beginning!(result, Statistics.mean(vbeg; dims=3)[:,:,1])
    set_ending!(result, Statistics.mean(vend; dims=3)[:,:,1])

    return result
end




df0 = copy(df)
df = cutoff(df)

cascade = Cascade2(df; numsample=1, kwargs...)
data = collect_data(cascade)

# convert(Cascade2{Horizontal}, cascade)

# Do all of the reordering.
numstep = length(cascade.steps)
iiorder = combinate(1:numstep)
c = Dict(ii => set_order!(copy(cascade), ii) for ii in iiorder)
d = Dict(k => collect_data(v) for (k,v) in c)

lst = collect(values(d))[1:2]

# Plot info for one of the values.
ks = iiorder[[1;length(iiorder)]]
c0 = Dict(k => Cascade(d[k][1], d[k][end], d[k][2:end-1]) for k in ks)
p0 = Dict(k => Plot{Horizontal}(Plot(v; ylabel="Efficiency (%)")) for (k,v) in c0)

# Save information about the mean.
data_mean = calculate_ordered_mean(lst)
cascade_mean = Cascade(data_mean[1], data_mean[end], data_mean[2:end-1])
p_mean = Plot{Horizontal}(Plot( ; cascade=cascade_mean, xaxis=p0[k].xaxis, yaxis=p0[k].yaxis), 0.01)

# p_mean = Plot{Horizontal}(Plot(Cascade(data_mean[1], data_mean[end], data_mean[2:end-1]); ylabel="Efficiency (%)"))

# Plot things.
for k in ks
    Luxor.@png begin
        Luxor.fontsize(14)
        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

        draw(p0[k]; distribution=distribution, samples=numsample, opacity=0.5)
        draw(p_mean, true; distribution=distribution, samples=numsample, style=:stroke, showaxis=false)

    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER string(k...)*".png"
end

# p_mean = Plot( ; cascade=Horizontal(data_mean))

# Cascade()

# v = Statistics.mean(get_value(srt); dims=1)
# vbeg = Statistics.mean(get_beginning(srt); dims=1)
# vend = Statistics.mean(get_ending(srt); dims=1)

# get_beginning(data)

# function calculate_height(data::Vector{Data})
#     vbeg = get_beginning(data)
#     vend = get_ending(data)

# end