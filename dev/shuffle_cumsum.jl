using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

"This function returns all permutations of the elements in the input vectors or vector of vectors"
permute(x::Vector{Vector{T}}) where T<: Any = permute(x...)
permute(x::Vararg{Any}) = vec(collect(collect.(Iterators.product(x...))))

"This function returns all of the ways to combine the elements in `lst`. At the moment,
due to memory size, this will truncate to a maximum length of `maxlen=6`."
function combinate(lst::AbstractArray; maxlen=6)
    lst = collect(lst)[1:max(length(lst),maxlen)]
    x = fill(collect(lst), length(lst))
    x = permute(x)
    return sort(x[vec(length.(unique.(x)).==length.(x))])
end

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

