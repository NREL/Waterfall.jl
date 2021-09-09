using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

# List of permutations.
perms = vcat([[
    ii,
    swapat!(copy(ii), 1, 2),
] for ii in [collect(1:4)]]...)


# !!!! Add support for defining a legend to violin plots.
for T in [Horizontal, Vertical, Parallel]
    for nsample in [1,10,50]
        for colorcycle in [true,false]
            for perm in perms

                (length(perm)>length(COLORCYCLE) && colorcycle) && continue
                
                # Define keyword arguments specific to this iteration.
                # By default, permute and correlate kwargs = true.
                global locals = (
                    # What modifications should be made to the input data?
                    nsample = nsample,
                    permutation = perm,
                    # How should the plot be formatted?
                    colorcycle = colorcycle,
                    ylabel = "Efficiency (%)",
                )
                
                global cascade = define_from(Cascade{Data}, df; locals..., kwargs...)
                global plot = define_from(Plot{T}, copy(cascade); locals..., kwargs...)

                Luxor.@png begin
                    Luxor.fontface("Gill Sans")
                    Luxor.fontsize(FONTSIZE)
                    Luxor.setline(1.0)
                    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

                    draw(plot)
                    
                end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+padding(plot.axes[1]) plot.path
            end
        end
    end
end