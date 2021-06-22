using Waterfall
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","correlate.jl"))

function cutoff(df::DataFrames.DataFrame; nstep=6, value=:Value)
    ii = [1; sortperm(abs.(df[2:end-1,value]); rev=true)[1:nstep].+1; size(df,1)]
    return df[ii,:]
end

function plot(x::Waterfall.Cascade)
    A = copy.(x.correlation-I)
    df = convert(DataFrames.DataFrame, rowprod!(x))
    N = size(df,2)

    StatsPlots.gr(size=(1000,1000), markerstrokewidth=1)

    s = StatsPlots.@df df StatsPlots.corrplot(cols(1:N),
        grid = false,
        markeralpha = 0.4,
        tickfontsize = 8,
        xaxis = (tickfontrotation = 60.0),
    )

    [StatsPlots.annotate!(s[ii,jj],
        Statistics.mean(StatsPlots.xlims(s[ii,jj])),
        StatsPlots.ylims(s[ii,jj])[end],
        StatsPlots.text(Printf.@sprintf("%.2g", A[ii-1,jj-1]), :center, :middle, 8)
        )
        for ii in 3:N-1 for jj in 2:ii-1 if A[ii-1,jj-1]!==0.0
    ]

    StatsPlots.savefig("correlation.png")
end


nstep = 4
nsample = 1000
nperm = 10
ncor = 2

plot(Waterfall.Cascade(cutoff(df; nstep=nstep);
    minrot=0.5,
    maxrot=0.75,
    nsample=nsample,
    ncor=ncor,
    kwargs...),
)

# plot_correlation(cascade)
# plot_cascade(cascade)