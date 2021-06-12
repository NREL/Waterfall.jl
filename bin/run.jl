using Waterfall


# Define highlights to mark.
prob = [0.75,0.25]
highlights=["mean"; [("quantile",p) for p in prob]]


for samples in [1,5,10,50]
    pdata = Plot(df; numsample=samples, ylabel=:Units, kwargs...)
    
    # Iterate over plot type.
    for T in [Horizontal,Parallel,Vertical,Violin]
        p = Plot{T}(pdata)

        # Show different combinations of labeling.
        for hh in [[], [1], 1:length(highlights)]
        # for hh in [[]]
            (samples==1 && !isempty(hh)) && continue

            f = filename(p, highlights[hh]; distribution=distribution)
            Printf.@printf("\nPlotting and saving figure to %s", f)

            Luxor.@png begin
                Luxor.fontsize(14)
                Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

                draw(p; distribution=distribution, samples=samples)

            end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER f
        end
    end
end