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
* Usage:
    - [ ] Read options from YAML file
    - [ ] Wrap plotting in a function.
* Default visualization features:
    - [ ] Label each waterfall in the with distribution method, mean, and variance.
    - [ ] Add error bars to mean
    - [x] Add legend.
* Add option to...
    - [x] Display parallel coordinates lines.
    - [ ] Display box plots on either end of each waterfall.
    - [x] Highlight metrics other than mean (quantile, etc.)
    - [ ] Color bars by correlation coefficient between current and previous step.
    - [ ] Select from distributions other than uniform and normal.
    - [ ] Reorder waterfalls to observe effect of order and sort by desirability.
* Add/update structures:
    - [ ] Violin: show cumulative mean at ending.
    - [ ] Options: 
    - [ ] Legend: gain/loss color; 