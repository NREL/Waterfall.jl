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