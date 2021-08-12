mutable struct Stroke <: Asset
    color::Union{Blending,Coloring}
    style::Union{Symbol, Vector{Float64}}
    width::Float64
end

function Stroke( ; color, style=:stroke, width=1.0, kwargs...)
    # :stroke, :dash, :dot, :dashdot, :dashdotdot
    return Stroke(color, style, width)
end


function _stroke( ; strokecolor, strokealpha=1.0, strokestyle, strokewidth)
    return Stroke(Coloring( ; hue=strokecolor, alpha=strokealpha), strokestyle, strokewidth)
end