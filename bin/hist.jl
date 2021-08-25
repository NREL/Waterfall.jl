using Waterfall
import Plots

# This file generates a histogram for each step in the cascade. It shows how a step HEIGHT
# depends on plotting order.
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

nperm = 1000
x = define_permute(df[[1:11;15],:], nperm; kwargs...)

data = collect_data(x)
N = length(data)

v = get_value(data)
lab = get_label.(data)
sublab = uppercase.(get_sublabel.(data))
title = ["$(sublab[ii]) ($(lab[ii]))" for ii in 1:N]

ii=6
for ii in 2:11
    Plots.histogram(v[ii,:];
        title=title[ii],
        xlabel="Efficiency (%)",
        color=COLORCYCLE[ii-1],
        legend=false,
        ylim=(0,1000),
        # xlim=(-2.,-1.,),
    )
    Plots.png(joinpath("fig","hist",name(ii-1)))
end

for ii in [1,N]
    Plots.histogram(v[ii,:];
            title=title[ii],
            xlabel="Efficiency (%)",
            color="black",
            legend=false,
            ylim=(0,1000),
            # xlim=(-2.,-1.,),
        )
    Plots.png(joinpath("fig","hist",name(ii-1)))
end



