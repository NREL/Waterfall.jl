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


# Read amounts and save investment order.

options = Dict(:Index=>"MJSP", :Technology=>"HEFA Camelina")
directory = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/b9a641ce-33be-3de3-b11f-3a53783e87e9"
subdirs = joinpath.(directory, readdir(directory))
subdirs = subdirs[isnothing.(match.(r"(.*[.].*)", subdirs))]

cascades = Dict()
plots = Dict()

for subdir in subdirs[[1]]
    println("")
    println(directory)
    println(subdir)
    local cascade = read_from(Cascade{Data}, subdir; options=options, kwargs...)
    global plot = read_from(Plot{T}, subdir;
        legend = (Statistics.quantile, 0.5),
        options = options,
        kwargs...,
    )

    global cascades[parse.(Int, split(splitpath(subdir)[end],""))...] = copy(cascade)
    # global plot[]

    N = 2
    Luxor.@png begin
        Luxor.fontface("Gill Sans")
        Luxor.fontsize(FONTSIZE)
        Luxor.setline(2.0)
        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

        # draw(plot, 2)
        animate(plot, N)
        println("Saving $(_title_animation_step(plot.path,N))")
        
    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+height(plot) _title_animation_step(plot.path,N)
end