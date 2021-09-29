using Waterfall


# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
FONTSIZE = 24


# List of permutations.
perms = vcat([[
    ii,
    swapat!(copy(ii), 1, 2),
] for ii in [collect(1:4)]]...)


# !!!! Add support for defining a legend to violin plots.
for T in [Horizontal, Vertical, Parallel, Violin]
    for nsample in [1,10,50][[2]]
        for colorcycle in [true,false]
            for perm in perms
                rngs = [
                    missing;
                    UnitRange.(1, 1:length(cascade));
                ]
                for rng in rngs

                    (length(perm)>length(COLORCYCLE) && colorcycle) && continue
                    
                    # Define keyword arguments specific to this iteration.
                    # By default, permute and correlate kwargs = true.
                    global locals = (
                        # What modifications should be made to the input data?
                        nsample = nsample,
                        permutation = perm,
                        rng = rng,
                        # How should the plot be formatted?
                        colorcycle = colorcycle,
                        ylabel = "Efficiency (%)",
                        legend = (Statistics.quantile, 0.5),
                    )
                    
                    global cascade = define_from(Cascade{Data}, df; locals..., kwargs...)
                    global plot = define_from(Plot{T}, copy(cascade);
                        subdir=string(T),
                        locals...,
                        kwargs...,
                        vmin = 16.0,
                        vmax = 22.5,
                    )

                    Luxor.@png begin
                        Luxor.fontface("Gill Sans")
                        Luxor.fontsize(FONTSIZE)
                        Luxor.setline(2.0)
                        Luxor.setmatrix([1 0 0 1 left_border(plot) top_border(plot)])
                        draw(plot)

                        println("Saving to: " * relpath(plot.path))
                    end width(plot) height(plot) plot.path
                end
            end
        end
    end
end