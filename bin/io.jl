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


DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
df = df[[1:11;15],:]

df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
df[!,:Units] .= "Efficiency (%)"

# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.3)
sample=:Sample
value=:Value
label=:Step
sublabel=:Process
nsample=5
ncor=2
minrot=0.01
maxrot=0.3

kwargs = (
    label=label,
    sublabel=sublabel,
    distribution=distribution,
    fuzziness=fuzziness,
    minrot=minrot,
    maxrot=maxrot,
    # ncor=ncor,
    # nsample=nsample,
)