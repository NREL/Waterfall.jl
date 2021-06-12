# Input editing
SAMPLES = 5
FUZZINESS = (0.01,0.3)
DISTRIBUTION = :normal      # linear, normal, triangular
NUMCORRELATED = 2

# Display
DISPLAY_MEAN = true
MEAN_STYLE = [nothing, :stroke, :fill, :gradient]
# 1. Horizontal (overlayed horizontal bars with opacity)
# 2. Vertical
#   - column to sort: Sample.start; all
#   - sort column by: sample mean, cumulative sum of previous values
#   - align at: beginning, ending, middle
# 3. Mean
#   - align at: middle
#   - source (location): cumulative sum of previous values (beginning) vs. sample (ending)
#   - visualization for each source:
#       - box,
#       - vertical histogram,
#       - horizontal histogram,
#       - violin plot (probably with opacity)