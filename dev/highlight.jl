using Waterfall

include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrame)
df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")

# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.1)
kwargs = (label=:Label, distribution=distribution, fuzziness=fuzziness)

# Define highlights to mark.
prob = [0.75,0.25]
highlights=["mean"; [("quantile",p) for p in prob]]

for show_stc in [false,true]
    for subdivide in [true,false]

        # Plot for different sample numbers.
        for samples in [1,5,10,50]
            cascade = Cascade(df; samples=samples, kwargs...)
            data = collect_data(cascade)
            set_order!(cascade, sortperm(get_value(cascade.start)))
            
            pdata = Plot(cascade; ylabel="Efficiency (%)")
            
            # Iterate over plot type.
            for T in [Vertical, Horizontal, Parallel]
                (T!==Parallel && !(subdivide*show_stc)) && continue

                p = Plot{T}(pdata; subdivide=subdivide)

                # Show different combinations of labeling.
                for hh in [[], [1], 1:length(highlights)]
                    (samples==1 && !isempty(hh)) && continue
                    
                    f = filename(p, highlights[hh]; distribution=distribution)
                    Printf.@printf("\nPlotting and saving figure to %s", f)

                    @png begin
                        fontsize(14)
                        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

                        draw(p; show_stc=show_stc, distribution=distribution, samples=samples)
                        _draw_highlight(pdata, highlights[hh])

                    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER f
                end
            end
        end

        # Separate parallel plots by settings.
        path = joinpath(FIG_DIR, "parallel")
        path_new = joinpath(path, "stc$(Int(show_stc))_subdivide$(Int(subdivide))")
        files = [x for x in readdir(path) if getindex(splitext(x),2)==".png"]

        !isdir(path_new) && mkpath(path_new)
        [mv(joinpath(path,file), joinpath(path_new,file); force=true) for file in files]
    end
end