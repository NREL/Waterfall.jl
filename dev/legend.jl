include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

locals = (
    nsample = 3,
    # permutation = perm,
    permute = true,
    ncor = true,
    correlate = true,
    colorcycle = false,
    ylabel = "Efficiency (%)",
    vmin = 12.0,
);

# args = (Statistics.mean,)
# pos = scale_for(cascade, Horizontal, args...; locals..., kwargs...)


lab = _define_annotation(cascade, Horizontal, Statistics.mean)
cas = set_geometry(cascade, Horizontal, Statistics.mean; locals..., kwargs...)




# vlims = vlim(cascade; locals..., kwargs...)
# pos = scale_for(calculate(copy(cascade), args...), Horizontal; kwargs...)

# lab = _define_annotation(cascade, Horizontal, args...)

# v = get_value(collect_data(cascade))