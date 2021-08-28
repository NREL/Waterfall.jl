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


include(joinpath(WATERFALL_DIR,"src","Figure","Color","Coloring.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Color","Blending.jl"))

abstract type Shape end
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Box.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Line.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Point.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Poly.jl"))

include(joinpath(WATERFALL_DIR,"src","Figure","Text","Labelbox.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Text","Label.jl"))

abstract type Sampling end
abstract type Geometry <: Sampling end
include(joinpath(WATERFALL_DIR,"src","Cascade","Data.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Cascade.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Geometry","Horizontal.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Geometry","Parallel.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Geometry","Vertical.jl"))
include(joinpath(WATERFALL_DIR,"src","Cascade","Geometry","Violin.jl"))

include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Arrow.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Box.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Line.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Point.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Shape","Poly.jl"))

abstract type Axis end
include(joinpath(WATERFALL_DIR,"src","Figure","Ticks.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","XAxis.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","YAxis.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Legend.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Annotation.jl"))
include(joinpath(WATERFALL_DIR,"src","Figure","Plot.jl"))

include(joinpath(WATERFALL_DIR,"src","definitions.jl"))
include(joinpath(WATERFALL_DIR,"src","options.jl"))

include(joinpath(WATERFALL_DIR,"src","utils","attributes.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","io.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","calc.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","draw.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","random.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","scale.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","utils.jl"))

include(joinpath(WATERFALL_DIR,"src","utils","define.jl"))