using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
dfamt = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-amounts.csv"), DataFrames.DataFrame)

samples=2
distribution=:normal
fuzziness=(0.01,0.1)
mean=true
kwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

parallel_coordinates = true

for samples in [1,5,10,50]
    for mean in [true,false]
        samples*mean == 1 && continue

        localkwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

        local cascade = Cascade(df; localkwargs...)
        local data = collect_data(cascade)
        set_order!(cascade, sortperm(get_value(cascade.start)))

        pdata = Plot(cascade; ylabel="Efficiency (%)")

        mean && (pmean = calculate_mean(pdata))
        local p025 = calculate_quantile(pdata, 0.25)
        local p075 = calculate_quantile(pdata, 0.75)


        # POINTS. SORTED BY FIRST.
        for T in [Violin, Scatter, Vertical, Horizontal]
            local p = Plot{T}(pdata)
            local f = filename(p; distribution=distribution, mean=mean)

            @png begin
                Luxor.fontsize(14)
                Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])
                # draw(p.cascade, ff)
                _draw_title(titlecase("$distribution Distribution"),"N = $samples")

                draw(p)

                mean && draw(pmean.cascade; style=:stroke, opacity=1.0)
                # draw(p025.cascade; hue="black", style=:stroke, opacity=0.8)
                # draw(p075.cascade; style=:stroke)


            end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER f
            Printf.@printf("\nSaving figure to %s", f)
        end
    end
end