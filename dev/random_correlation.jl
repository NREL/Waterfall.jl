using StatsPlots
using IndexedTables

# This demonstrates the PROCESS by plotting a correlation matrix I THINK.
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

begin value=:Value; label=:Label; sample=:Sample end
distribution=:normal
fuzziness=(0.01,0.3)
numsample=1000
ncor=2
kwargs = (label=label, distribution=distribution, fuzziness=fuzziness,
    numsample=numsample,
    ncor=ncor,
)


df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
df[!,:Units] .= "Efficiency (%)"

label=:Process
df = DataFrames.transform(fuzzify(df; kwargs...))
dfw = DataFrames.unstack(DataFrames.select(df, [sample,label,value]), label, value)
steps = size(dfw,2)-1

cols = propertynames(dfw)[2:end]
vcorr = random_correlation(steps, ncor)
# @df iris corrplot(cols(1:4), grid = false)

StatsPlots.gr(size=(800,800))

iis = sum(hcat([vcat(sum(LinearAlgebra.UnitLowerTriangular(vcorr); dims=ii)...) for ii in 1:2]...); dims=2).!==2.0
iis = unique([[ii for ii in collect(2:steps+1) .* iis if ii!==0]; steps+1])

@df dfw StatsPlots.corrplot(cols(iis),
    grid=false,
    compact=true,
    label =["$i" for i=iis],
)

# using StatsPlots
# using IndexedTables


# import RDatasets


# df = DataFrames.DataFrame(a = 1:10, b = 10 .* rand(10), c = 10 .* rand(10))
# @df df plot(:a, [:b :c], colour = [:red :blue])
# @df df scatter(:a, :b, markersize = 4 .* log.(:c .+ 0.1))
# t = table(1:10, rand(10), names = [:a, :b]) # IndexedTable
# @df t scatter(2 .* :b)

# @df df plot(:a, cols(2:3), colour = [:red :blue])

# # SCHOOL
# # school = RDatasets.dataset("mlmRev","Hsb82")
# # @df school density(:MAch, group = (:Sx, :Sector), legend = :topleft)