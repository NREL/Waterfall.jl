# Waterfall.jl

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

## Development Plans
[ ] Add parallel coordinates lines.
[ ] Read options from YAML file.
[ ] Wrap plotting in a function.
[ ] Label each waterfall in the cascade.
[ ] Reorder waterfalls to observe effect of order and sort by desirability.
[ ] Highlight metrics other than mean (quantile, etc.)
[ ] Add error bars to mean
[ ] Add option to plot mean
[ ] Add legend.
[ ] Add option to display box plots in addition to violin plots.