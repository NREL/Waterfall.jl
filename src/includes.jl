import DataFrames
# using InvertedIndices
import Luxor

import Base
import CSV
import Printf

import Combinatorics
import Statistics
import StatsBase
import Random
import Distributions
import KernelDensity
import SparseArrays

import LinearAlgebra, LinearAlgebra.I

abstract type Sampling end
abstract type Geometry <: Sampling end

include(joinpath(WATERFALL_DIR,"src","Cascade","Data.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Cascade.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Horizontal.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Parallel.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Vertical.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Violin.jl"))

include(joinpath(WATERFALL_DIR,"src","Figure","Coloring.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Blending.jl"))

include(joinpath(WATERFALL_DIR,"src","Figure","Attributes.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Axis.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Legend.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Annotation.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Plot.jl"))

include(joinpath(WATERFALL_DIR,"src","definitions.jl"))
include(joinpath(WATERFALL_DIR,"src","options.jl"))

include(joinpath(WATERFALL_DIR,"src","utils","io.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","calc.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","correlate.jl"))
# include(joinpath(WATERFALL_DIR,"src","utils","draw.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","random.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","scale.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","utils.jl"))