using Waterfall
import Luxor
import Base
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
# include(joinpath(WATERFALL_DIR,"src","utils","correlate.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","draw.jl"))

nstep = 3
nsample = 1
nperm = 1000
ncor = 1000
N = 13
permute = false
permutations = [[collect(1:N)]; Waterfall.random_permutation(1:N, min(factorial(N),nperm))]

cascades = Dict()
heights = Dict()
plots = Dict()

for k in permutations
# k = permutations[1]
    x = Cascade(df; permutation=k, nsample=nsample, ncor=ncor, kwargs...)
    push!(cascades, k => x)

    # Calculate the value we will want to add to a NEW cascade. This will come from the
    # HEIGHT of the current cascade.
    v1, v2 = Waterfall.cumulative_v!(x; permute=permute)
    push!(heights, k => v2 .- v1)
end

# Make dictionary of heights into one cascade.
vals = convert(Matrix, [heights[k] for k in permutations])
data = Waterfall.collect_data(cascades[permutations[1]])

data = [Data( ; value=vals[:,ii], label=data[ii].label, sublabel=data[ii].sublabel) for ii in 1:length(data)]
cascade = Cascade( ; start=first(data), stop=last(data), steps=data[2:end-1], ncor=0)

pdata = Plot(copy(cascade); ylabel="Efficiency (%)")
# p = convert(Plot{Violin}, pdata, 1.0; permute=false, vmin=15., vmax=20.5)


# calculate_kde(v::Vector{T}) where T <: Real = KernelDensity.kde(v)


# Luxor.@png begin
#     Luxor.fontsize(18)
#     Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

#     draw(p; distribution=distribution, samples=nsample)
# end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER "many-cascades.png"

# df0 = copy(df)
# df0 = DataFrames.transform(Waterfall.fuzzify(df0; nsample=1, kwargs...))

# # df = DataFrames.hcat(df, df; makeunique=true)
# df = convert(DataFrames.DataFrame, cascade)[:,2:end-1]
# # df = DataFrames.rename.(df, Pair.(DataFrames.propertynames(df), Symbol.(df0[2:end-1,:Label])))
# df[!,:permutation] .= permutations
# df = DataFrames.stack(df, 1:size(df,2)-1)
# # df = df[df[:,:variable] .== "2",:]
# StatsPlots.@df df StatsPlots.violin(:variable, :value, linewidth=0)
# # @df iris groupedhist(:value, group = :variable, bar_position = :dodge)
# # # DataFrames.stack(df)