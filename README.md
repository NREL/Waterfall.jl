# Waterfall.jl: Investment impact visualization

This Waterfall.jl graphics package provides support to visualize, with uncertainty, the impact of sequential investments on a given metric (i.e., cost, emissions). The first column of the waterfall plot shows the value before any investment has been made, and each subsequent column shows the increase or decrease in value after a single investment until the final column shows the projected value after all investments have been made. Waterfall plots are unique in that the order in which investments are plotted impacts both the shape of the graphic and the values of each individual result: each value encompasses the effects of not only the current investment, but of all investments before it. The impact of any investments plotted after it, however, will not be included in the visualization. This has the effect in obscuring correlations between investments and changing the results themselves as an artifact of decisions surrounding plotting order. Furthermore, there is no currently accepted method of visualizing uncertainty in waterfall plots.

This package aims to address these visualization challenges. The package includes methods to inject uncertainty into data by replacing each data point by a random uniform or normal distribution centered at its value, and, if desired, adding random correlation to the sets of samples. This aides in generating "toy" data necessary to assess the challenges of visualizing correlated samples with waterfall plots and to add uncertainty to the plots.

Given either randomly-generated samples or model output (with the results of each investment stored in a separate spreadsheet), the package calculates and draws the magnitude at each investment step.
The package also provides four visualization options to provide a user flexibility in how they want to display uncertainty:
1. Horizontal, all samples are overlaid with opacity;
2. Vertical, all samples are shown as individual bars;
3. Parallel, all samples are overlaid as lines from one investment to the next; and
4. Violin, a violin plot at each step is used to show the distribution of sample values.

There is the option to outline statistical values, with median sample value shown by default. Users are given the option to assign plot color such that each investment step is uniquely colored or such that there is a distinction between gains and losses. Up to 10 investments can be shown with distinguishable colors.


## Installation

Clone this repo to your local machine.

```
> git clone https://github.com/NREL/Waterfall.jl.git
```

From the `Waterfall.jl` directory, open Julia using

```
> julia --project
```

Build the `Waterfall` package from the Pkg REPL. Type `]` to enter the Pkg REPL and run:

```julia
(Waterfall) pkg> build
```

This will generate the `Manifest.toml` file, including the package dependencies.
Package features (this far) are maintained in `bin/run.jl`.
Run this file to generate waterfall plots and edit this file to customize input.