using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrame)
dfamt = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-amounts.csv"), DataFrame)

samples=5
distribution=:normal
fuzziness=(0.01,0.1)
mean=true
kwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

parallel_coordinates = true

# for samples in [5,10,50]
for samples in [5]

    prob = [0.75,0.25]
    highlight_stat=["mean"; [("quantile",p) for p in prob]]
    dash_stat=["solid"; [10*[p,1-p] for p in prob]]

    # highlight_stat = highlight_stat[[1]]
    # dash_stat = dash_stat[[1]]

    # for mean in [true,false]
        # samples*(highlight_stat=="mean") == 1 && continue

        localkwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

        cascade = Cascade(df; localkwargs...)
        data = collect_data(cascade)
        set_order!(cascade, sortperm(get_value(cascade.start)))

        pdata = Plot(cascade; ylabel="Efficiency (%)")

        # mean && (pmean = calculate_mean(pdata))
        # local p025 = calculate_quantile(pdata, 0.25)
        # local p075 = calculate_quantile(pdata, 0.75)

        # POINTS. SORTED BY FIRST.
        for T in [Vertical, Horizontal, Parallel]
        # T = Vertical
            p = Plot{T}(pdata; subdivide=false)
            f = filename(p, highlight_stat; distribution=distribution)
            # f = filename(p; distribution=distribution, mean=true)

            @png begin
                fontsize(14)
                Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])
                # draw(p.cascade, ff)
                _draw_title(titlecase("$distribution Distribution"),"N = $samples")

                draw(p)

                fontsz = get_fontsize()
                y0 = SEP + 2*fontsz
                dy = 1.5*fontsz
                hbox = 0.5*fontsz
                
                x0 = 0.8*WIDTH
                wbox = SEP

                # Draw mean and %ile box
                for kk in 1:length(highlight_stat)
                    println(length(get_value(pdata.cascade.start)))
                    setline(1)

                    Luxor.setdash(dash_stat[kk])
                    draw(highlight(pdata, highlight_stat[kk]).cascade; hue="black", style=:stroke, opacity=1.0)
                    
                    y = y0+dy*(kk-1)
                    local x = [x0-wbox*(ii-1) for ii in 1:4]

                    setcolor(sethue("black")...,1.)
                    # setblend(blend(Point(x[3],y-hbox), Point(x[3],y+hbox), HEX_LOSS, HEX_GAIN))
                    Luxor.box(Point(x[4],y-hbox), Point(x[2],y+hbox), :stroke)
                    Luxor.text(_label_stat(highlight_stat[kk]), Point(x[1],y); halign=:left, valign=:middle)

                end

                # Parallel coordinates.
                # pmean = highlight(pdata, "mean")

                # p1 = [first(getindex.(pmean.cascade.steps[ii].points,1)) for ii in 1:12]
                # p2 = [first(getindex.(pmean.cascade.steps[ii].points,1)) for ii in 2:13]
                # [line(p1[ii],p2[ii], :stroke) for ii in 1:12]

            end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER f
            Printf.@printf("\nSaving figure to %s\n", f)
        end



    # end
end