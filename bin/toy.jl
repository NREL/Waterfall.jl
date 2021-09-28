using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

import Base
import Combinatorics
import CSV
import DataFrames
import LinearAlgebra, LinearAlgebra.I
import Printf
import SparseArrays
import Statistics
import StatsPlots
using Query

DATA_DIR = joinpath(WATERFALL_DIR,"data")
df = CSV.read(joinpath(DATA_DIR,"toy","saf.csv"), DataFrames.DataFrame)
DataFrames.select!(df, DataFrames.Not([:Column1,:Variable]))

value = :Value
sample = :Sample
label = :Technology
sublabel = :Scenario
metric = :Index

# Number of rows in cascade.
technologies = unique(df[:,:Technology])
N = length(technologies)
permutation = collect(1:N)

# Which investments were selected?
Random.seed!(SEED)
scenarios = unique(df[:,:Scenario])
scenarios = scenarios[rand(1:3,N)]

# Filter the results DataFrame to show only the selected investment for each technology.
filtering = DataFrames.DataFrame(
    sample => 1:5,
    label => technologies,
    sublabel => scenarios,
    metric => "MJSP",
)
df = DataFrames.innerjoin(df, filtering, on=propertynames(filtering))
df[!,label] = replace.(df[:,label], r"HEFA\s"=>"")

kwargs = (
    value = value,
    sample = sample,
    label = label,
    sublabel = sublabel,
    metric = metric,
    correlate = false,
    nsample = maximum(df[:,sample]),
    # How should the plot be formatted?
    colorcycle = false,
    ylabel = "MJSP (USD/gal)",
)

# cascade = define_from(Cascade{Data}, df; kwargs...)
data = define_from(Vector{Data}, df; kwargs...)

cascade = Cascade(
    start = first(data),
    stop = last(data),
    steps = data[2:end-1],
    correlation = I(N),
    permutation = permutation,
    iscorrelated = false,
    ispermuted = false,
)

T = Horizontal
plot = define_from(Plot{T}, copy(cascade); kwargs...)


Luxor.@png begin
    Luxor.fontface("Gill Sans")
    Luxor.fontsize(FONTSIZE)
    Luxor.setline(1.0)
    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

    draw(plot)
    
end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+height(plot.axes[1]) "saf.png"