p = Plot(df; samples=100, ylabel=:Units, kwargs...)
v = get_value(collect_data(p.cascade))

covariance = LinearAlgebra.LowerTriangular(Statistics.cov(v, v; dims=2))
correlation = LinearAlgebra.LowerTriangular(Statistics.cor(v; dims=2))
# # variance = Statistics.var(v; dims=2) # == LinearAlgebra.diag(covariance)


labels = df[:,:Label]
steps = 4
global plots = fill(Plots.Plot(), (steps,steps))
for ii in 1:steps
    for jj in 1:ii
        if ii!==jj
            plots[ii,jj] = Plots.scatter(v[ii,:], v[jj,:],
                xlabel=labels[ii],
                ylabel=labels[jj],
                label=round(Statistics.cor(v[ii,:], v[jj,:]); sigdigits=4),
                xguidefontsize=8,
                yguidefontsize=8,
            )
        else
            plots[ii,jj] = Plots.histogram(v[ii,:],
                xlabel=labels[ii],
                label="",
                xguidefontsize=8,
                yguidefontsize=8,
            )
        end
    end
end

plots = plot(plots..., layout=(steps,steps), size=(1000,1000))

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
