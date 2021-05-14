using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrame)
dfamt = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-amounts.csv"), DataFrame)

samples=2
distribution=:normal
fuzziness=(0.01,0.1)
mean=true
kwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)


for mean in [true,false]
    for samples in [1,5,50]
        samples*mean == 1 && continue

        localkwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

        local cascade = Cascade(df; localkwargs...)
        local data = collect_data(cascade)
        set_order!(cascade, sortperm(get_value(cascade.start)))

        local pviolin = Plot{Violin}(cascade; ylabel="Efficiency (%)")
        local pscatter = Plot{Scatter}(cascade; ylabel="Efficiency (%)")
        local pvertical = Plot{Vertical}(cascade; ylabel="Efficiency (%)")
        local phorizontal = Plot{Horizontal}(cascade; ylabel="Efficiency (%)")

        local cmean = calculate_mean(cascade)
        local vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
        local pmean = Plot{Horizontal}(cmean, vlims; ylabel="Efficiency (%)")
        
        # POINTS. SORTED BY FIRST.
        for p in [phorizontal, pviolin, pvertical, pscatter]
            local f = filename(p; distribution=distribution, mean=mean)
            @png begin
                fontsize(14)
                Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])
                # draw(p.cascade, ff)
                draw(p)
                mean && draw(pmean.cascade; style=:stroke, opacity=1.0)
            end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER f
            Printf.@printf("\nSaving figure to %s", f)
        end
    end
end