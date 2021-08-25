# include(joinpath(WATERFALL_DIR,"src","includes.jl"))
import Base
import Combinatorics
import CSV
import DataFrames
import LinearAlgebra, LinearAlgebra.I
import Printf
import SparseArrays
import Statistics
import StatsPlots


# DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
# df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)

DATA_DIR = joinpath(WATERFALL_DIR,"data")
df = CSV.read(joinpath(DATA_DIR,"investment.csv"), DataFrames.DataFrame)
[df[!,ii] .= coalesce.(df[:,ii],missing,"") for ii in 1:size(df,2)]
# df = df[[1:11;15],:]

# df[!,:Process] .= replace.(df[:,:Process], "interconnection"=>"intercon")
# df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
# df[!,:Units] .= "Efficiency (%)"


# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.3)
interactivity=(0.2,0.4)
sample=:Sample
value=:Value
label=:Step
sublabel=:Process
nsample=5

kwargs = (
    label=label,
    sublabel=sublabel,
    distribution=distribution,
    fuzziness=fuzziness,
    interactivity=interactivity,
    # vmin=12.0,
    # ncor=ncor,
    # nsample=nsample,
)