include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
df[!,:Units] .= "Efficiency (%)"

# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.3)
value=:Value
label=:Label
numcorrelated=2
kwargs = (
    label=label,
    distribution=distribution,
    fuzziness=fuzziness,
    numcorrelated=numcorrelated,
)