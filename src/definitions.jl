const FIG_DIR = joinpath(WATERFALL_DIR,"fig")

# Dimensions
const WIDTH = 800
const HEIGHT = 400
const BORDER = 10
const TOP_BORDER = 20
const BOTTOM_BORDER = 40
const LEFT_BORDER = 60
const RIGHT_BORDER = 20
const SEP = 10

# Names
const SAMPLE_COL = :Sample
const VALUE_COL = :Value

# Colors
const HEX_LOSS = "#EE442F"
const HEX_GAIN = "#63ACBE"

# Default input editing
const SEED = 1234
const DEFAULT_FUZZINESS = (0.01,0.3)
const DEFAULT_DISTRIBUTION = :normal      # linear, normal, triangular
const DEFAULT_NSAMPLE = 5
const DEFAULT_NCOR = true

# https://arxiv.org/abs/2107.02270
# https://github.com/mpetroff/accessible-color-cycles
COLORCYCLE = ["#3f90da", "#ffa90e", "#bd1f01", "#94a4a2", "#832db6", "#a96b59", "#e76300", "#b9ac70", "#717581", "#92dadd"]