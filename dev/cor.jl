# ******************************************************************************************
# REQUIRES PACKAGE: PLOTS (incompatible with StatsPlots, I think)
# ******************************************************************************************
using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
df[!,:Units] .= "Efficiency (%)"

# Define global arguments.
distribution=:normal
fuzziness=(0.01,0.3)
kwargs = (label=:Label, distribution=distribution, fuzziness=fuzziness)

p = Plot(df; samples=1000, ylabel=:Units, kwargs...)
v = get_value(collect_data(p.cascade))

covariance = LinearAlgebra.LowerTriangular(Statistics.cov(v, v; dims=2))
correlation = LinearAlgebra.LowerTriangular(Statistics.cor(v; dims=2))
# # variance = Statistics.var(v; dims=2) # == LinearAlgebra.diag(covariance)


labels = df[:,:Label]
steps = 15
global plots = fill(Plots.Plot(), (steps,steps))
for ii in 1:steps
    for jj in 1:ii
        begin xx=jj; yy=ii end

        plots[ii,jj] = if ii!==jj
            Plots.scatter(v[xx,:], v[yy,:],
                # xlabel=labels[xx],
                # ylabel=labels[yy],
                label="",
                # label=round(Statistics.cor(v[xx,:], v[yy,:]); sigdigits=4),
                xaxis=[],
                yaxis=[],
                xguidefontsize=8,
                yguidefontsize=8,
                markersize=2,
                markeralpha=0.5,
                markerstrokewidth=0,
            )
        else
            Plots.histogram(v[xx,:],
                xlabel=labels[xx],
                label="",
                xguidefontsize=8,
                yguidefontsize=8,
            )
        end
    end
end

N=5
plots = plots[1:N,1:N]
# allplots = plot(plots[1,1], plots[2,1], plots[1,2], plots[2,2], layout=(2,2))
allplots = plot(plots..., layout=size(plots), size=(800,800))

# printtype(x) = typeof(x)

# p1 = plot(...)
# p2 = plot(...)
# p3 = plot(...)
# plot(p1, p2, p3, layout = l)

# p = Plot{Parallel}(p)

# Luxor.@png begin
#     Luxor.fontsize(14)
#     Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

#     draw(p; distribution=distribution, samples=samples)
#     # _draw_highlight(pdata, highlights[hh])

# end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER "correlation.png"
