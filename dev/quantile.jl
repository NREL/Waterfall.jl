DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrame)
dfamt = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-amounts.csv"), DataFrame)

samples=5
distribution=:normal
fuzziness=(0.01,0.1)
mean=true
kwargs = (label=:Process, samples=samples, distribution=distribution, fuzziness=fuzziness)

cascade = Cascade(df; kwargs...)
plot = Plot(cascade; ylabel="Efficiency (%)")
data = collect_data(cascade)

c25 = calculate_quantile(plot.cascade, 0.25)
c75 = calculate_quantile(plot.cascade, 0.75)