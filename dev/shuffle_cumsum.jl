using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))


"This function returns a matrix of size (gdf.ngroups, gdf.ends[1]) of
DataFrames.GroupedDataFrame values."
get_value(gdf::DataFrames.GroupedDataFrame; val=:Value) = hcat([x[:,val] for x in gdf]...)'



df = df[1:8,:]

numsample=50
numstep=size(df,1)-2

gdf = fuzzify(df; numsample=numsample, kwargs...)
# df = DataFrames.transform(gdf)

# 
# (:parent, :cols, :groups, :idx, :starts, :ends, :ngroups, :keymap, :lazy_lock)
# dfg.starts -> dfg.stops

v = get_value(gdf)

iiorder = vcat.(1, combinate(2:numstep+1), numstep+2)
d = Dict(x=>v[x,:] for x in iiorder)

dsum = Dict(k => Statistics.cumsum(v; dims=1) for (k,v) in d)

dsum = Dict(k => vcat(fill(0,1,size(v,2)),Statistics.cumsum(v; dims=1)) for (k,v) in d)
dheight = Dict(k => dsum[k][2:end,:] .- dsum[k][1:end-1,:] for (k,v) in d)

# random_index()

# list_index(x...) = vec(collect(collect.(Iterators.product(x...))))
# myrand(x) = collect(collect.(Iterators.product(x...)))

