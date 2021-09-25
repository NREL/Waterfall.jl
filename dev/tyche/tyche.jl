using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

T = Horizontal
nsample = 10
value = :Value
sample = :Sample
label = :Category
sublabel = :Amount
colorcycle = true
kwargs = (value=value, sample=sample, label=label, colorcycle=colorcycle)

TOP_BORDER=48+SEP

# Read amounts and save investment order.

options = Dict(
    :Index=>"Reduction in MJSP",
    # :Index=>"Reduction in Jet GHG",
    :Technology=>"HEFA Camelina",
)

# Define the directory, and make sure only to save directory 
directory = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/6f84f6cf-0b43-31a2-9706-576272778f20"
subdirs = joinpath.(directory, readdir(directory))
subdirs = subdirs[.&(isnothing.(match.(r"(.*[.].*)", subdirs)), isnothing.(match.(r".*/fig", subdirs)))]

cascades = Dict()
plots = Dict()

for subdir in subdirs[[end]]
    println("")
    println(subdir)

    # When creating an animation, we first need to read the complete cascade to calculate
    # the y-axis limits in order to maintain consistent scaling throughout.
    global cascade = read_from(Cascade{Data}, subdir;
        options = options,
        kwargs...,
    )
    vlims = vlim(cascade; kwargs...)

    # for N = 1:length(cascade)
    for N = [length(cascade)]
        # Save to cascade dictionary.
        global cascades[parse.(Int, split(splitpath(subdir)[end],""))...] = copy(cascade)
        
        # Would be nice to use define_from here.
        global plot = read_from(Plot{T}, subdir;
            rng = 1:N,
            legend = (Statistics.quantile, 0.5),
            options = options,
            vlims...,
            kwargs...,
        )

        Luxor.@png begin
            Luxor.fontface("Gill Sans")
            Luxor.fontsize(FONTSIZE)
            Luxor.setline(2.0)
            Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

            draw(plot)
            Luxor.circle(Luxor.Point(0,0), 20)
            println("Saving to: " * plot.path)
            
        end WIDTH+LEFT_BORDER+RIGHT_BORDER  HEIGHT+TOP_BORDER+BOTTOM_BORDER+height(plot.axes[1])  plot.path
    end
end