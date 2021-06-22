# https://pkgdocs.julialang.org/v1/creating-packages/
#   julia
#   ] generate Waterfall
#   ; cd Waterfall
#   ] activate .
#   ] add DataFrames, Luxor, CSV, Statistics
#   import Waterfall

module Waterfall

WATERFALL_DIR = abspath(joinpath(dirname(Base.find_package("Waterfall")), ".."))
export WATERFALL_DIR

include("includes.jl")

export WIDTH
export HEIGHT
export BORDER
export TOP_BORDER
export BOTTOM_BORDER
export LEFT_BORDER
export RIGHT_BORDER
export SEP


export convert
export Cascade
export Data
export Geometry
export Sampling
export Parallel
export Vertical
export Axis

export Attributes
# export Legend
# export Annotation

export Coloring
export Blending

export Plot

# include("definitions.jl")
# include("utils.jl")

# export scale_height!
# export scale_width!
# export pick_random
# export pick_scenario
# export lower_triangular
# export combine_over

end