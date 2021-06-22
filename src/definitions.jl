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
const DEFAULT_FUZZINESS = (0.01,0.3)
const DEFAULT_DISTRIBUTION = :normal      # linear, normal, triangular
const DEFAULT_NSAMPLE = 5
const DEFAULT_NCOR = 2