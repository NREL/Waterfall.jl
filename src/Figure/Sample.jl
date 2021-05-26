mutable struct Sample
    start::Box
    difference::Array{Box,1}
    stop::Box
end

Sample(; start, difference, stop) = Sample(start, difference, stop)

function Sample(df::DataFrames.SubDataFrame; label, value, width=missing)
    N = size(df,1)
    CAT = N-2
    ismissing(width) && (width = (WIDTH-(N+1)*SEP)/N)

    start = Box(df[1,label]; value=df[1,value], height=df[1,value], width=width)
    difference = [Box(df[ii,label]; value=df[ii,value], height=df[ii,value], width=width) for ii in (1:CAT).+1]
    stop = Box(df[N,label]; value=sum(get_value.([start; difference])), height=sum(get_height.([start; difference])), width=width)
    
    return Sample(start, difference, stop)
end

# function Sample(df::DataFrames.DataFrame; kwargs...)
#     samples = [Sample(sdf; kwargs...) for sdf in groupby(df, :Sample)]
#     ymax = round(max_cumsum(samples))+0.5
#     ymin = floor(min_cumsum(samples)*0.9)
#     yscale = HEIGHT/(ymax-ymin)

#     N = length(get_boxes(first(samples)))
#     xscale = (WIDTH-(N+1)*SEP)/N

#     calculate_height!.(samples; ymin=ymin, yscale=yscale)

#     calculate_ymid!.(samples)
#     calculate_xmid!.(samples)

#     return samples
# end



function define_samples(df::DataFrames.DataFrame; kwargs...)
    samples = [Sample(sdf; kwargs...) for sdf in groupby(df, :Sample)]

    ymin, ymax, yscale = lim_value(samples)

    N = length(get_boxes(first(samples)))
    xscale = (WIDTH-(N+1)*SEP)/N

    calculate_height!.(samples; ymin=ymin, yscale=yscale)

    calculate_ymid!.(samples)
    calculate_xmid!.(samples)

    return samples
end


get_boxes(x::Sample) = [x.start; x.difference; x.stop]
get_start(x::Sample) = x.start
get_difference(x::Sample) = x.difference
get_stop(x::Sample) = x.stop