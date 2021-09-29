using Waterfall


# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
FONTSIZE = 24


# List of permutations.
ii = collect(1:4)
perms = vcat([
    ii,
    swapat!(copy(ii), 1, 2),
    [ii[2:end];ii[1]],
])

# !!!! Add support for defining a legend to violin plots.
nsamples = [1,10,50]
for T in [Horizontal, Vertical, Parallel, Violin][[2]]
    for nsample in nsamples[[2]]
        for colorcycle in [true,false]
            for perm in perms
                rngs = Any[missing]
                # nsample==10 && append!(rngs, UnitRange.(1, 1:nsample))
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
                        ylabel = "Cost (thousand USD)",
                        legend = (Statistics.quantile, 0.5),
                    )
                    
                    global cascade = if nsample==1
                        calculate!(
                            define_from(Cascade{Data}, df; locals..., kwargs..., nsample=nsamples[2]),
                            locals.legend...,
                        )
                    else
                        define_from(Cascade{Data}, df; locals..., kwargs...)
                    end

                    global plot = define_from(Plot{T}, copy(cascade);
                        subdir=string(T),
                        locals...,
                        kwargs...,
                        vmin = 16.0,
                        vmax = 22.5,
                    )
                    
                    if nsample==1
                        plot.title.text = [plot.title.text[1]," "]
                    end

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