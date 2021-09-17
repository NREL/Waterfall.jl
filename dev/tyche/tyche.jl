#= !!!!
    Make sure we have all of the optimization info.
    Maybe in a struct?
=# 

using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

T = Horizontal
nsample = 10
value = :Value
sample = :Sample
label = :Category
colorcycle = true
ylabel = "MJSP"

kwargs = (value=value, sample=sample, label=label, colorcycle=colorcycle, ylabel=ylabel)


"""
    _aggregate(data; kwargs...)

# Keyword Arguments
- `label`
- `sublabel`
- `order`
"""
function _aggregate(data; label, sublabel="", order=missing, kwargs...)
    value = Statistics.sum(get_value(data); dims=1)[1,:]
    order = coalesce(order, collect(1:length(value)))
    return Data( ; label=label, sublabel=sublabel, order=order, value=value)
end


# index = :Index => "Reduction in MJSP"
DATA_DIR = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/f79234a0-201a-3cb8-9a1a-d6766df2e4c6"

cascade = define_from(Cascade{Data}, DATA_DIR; kwargs...)
# plot = define_from(Plot{T}, DATA_DIR; kwargs...)

Luxor.@png begin
    Luxor.fontface("Gill Sans")
    Luxor.fontsize(FONTSIZE)
    Luxor.setline(1.0)
    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

    draw(plot)
    
end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+height(plot) plot.path