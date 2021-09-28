using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

T = Violin
nsample = 10
value = :Value
sample = :Sample
label = :Category
sublabel = :Amount
colorcycle = true
kwargs = (value=value, sample=sample, label=label, sublabel=sublabel, colorcycle=colorcycle)

TOP_BORDER=48+SEP

# Define the directory, and make sure only to save directory 
directory = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/6f84f6cf-0b43-31a2-9706-576272778f20"
subdirs = joinpath.(directory, readdir(directory))
subdirs = subdirs[.&(isnothing.(match.(r"(.*[.].*)", subdirs)), isnothing.(match.(r".*/fig", subdirs)))]

cascades = Dict()
plots = Dict()

subdir = subdirs[3]
idx = "Reduction in MJSP"
rng = missing

options = Dict(:Index=>idx, :Technology=>"HEFA Camelina")

# When creating an animation, we first need to read the complete cascade to calculate
# the y-axis limits in order to maintain consistent scaling throughout.
global cascade = read_from(Cascade{Data}, subdir;
    options = options,
    kwargs...,
)
global vlims = vlim(cascade; kwargs...)

global cascades[parse.(Int, split(splitpath(subdir)[end],""))...] = copy(cascade)

global plot = read_from(Plot{T}, subdir;
    legend = (Statistics.quantile, 0.5),
    options = options,
    rng = rng,
    vlims...,
    kwargs...,
)

Luxor.@png begin
    Luxor.fontface("Gill Sans")
    Luxor.fontsize(FONTSIZE)
    Luxor.setline(2.0)
    Luxor.setmatrix([1 0 0 1 left_border(plot) top_border(plot)])
    draw(plot)
    println("Saving to: " * relpath(plot.path))
end width(plot) height(plot) plot.path