const FIG_DIR = joinpath(WATERFALL_DIR,"fig")

# Dimensions
WIDTH = 800
HEIGHT = 400
BORDER = 10
TOP_BORDER = 20
BOTTOM_BORDER = 30
LEFT_BORDER = 70
RIGHT_BORDER = 20
SEP = 10
FONTSIZE = 18

VMAX = 22.5
VMIN = 16

# Names
const SAMPLE_COL = :Sample
const VALUE_COL = :Value

# Colors
const HEX_LOSS = parse(Luxor.Colorant,"#ca0020")
const HEX_GAIN = parse(Luxor.Colorant,"#0571b0")

# Default input editing
const SEED = 1234
const DEFAULT_FUZZINESS = (0.01,0.3)
const DEFAULT_DISTRIBUTION = :normal      # linear, normal, triangular
const DEFAULT_NSAMPLE = 5
const DEFAULT_NCOR = true

const LEADING = 1.25

# COLORCYCLE = Dict(
#     # https://colorbrewer2.org/?type=qualitative&scheme=Paired&n=12
#     :bright => ["#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffff99","#b15928"],
#     # https://colorbrewer2.org/?type=qualitative&scheme=Set3&n=12
#     :pastel => ["#8dd3c7","#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9","#bc80bd","#ccebc5","#ffed6f"],
#     # https://arxiv.org/abs/2107.02270
#     # https://github.com/mpetroff/accessible-color-cycles
#     6 => ["#5790fc", "#f89c20", "#e42536", "#964a8b", "#9c9ca1", "#7a21dd"],
#     8 => ["#1845fb", "#ff5e02", "#c91f16", "#c849a9", "#adad7d", "#86c8dd", "#578dff", "#656364"],
#     10 => ["#3f90da", "#ffa90e", "#bd1f01", "#94a4a2", "#832db6", "#a96b59", "#e76300", "#b9ac70", "#717581", "#92dadd"],
# )
# const COLORCYCLE = Dict(k => parse.(Luxor.Colorant, v) for (k,v) in COLORCYCLE)
COLORCYCLE = ["#3f90da", "#ffa90e", "#bd1f01", "#94a4a2", "#832db6", "#a96b59", "#e76300", "#b9ac70", "#717581", "#92dadd","#92dadd","#92dadd"]
# COLORCYCLE = ["#8dd3c7","#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9","#bc80bd","#ccebc5","#ffed6f"]
# COLORCYCLE = ["#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffff99","#b15928"]