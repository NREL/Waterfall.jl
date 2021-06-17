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
# include("definitions.jl")
# include("utils.jl")

# export scale_height!
# export scale_width!
# export pick_random
# export pick_scenario
# export lower_triangular
# export combine_over

end