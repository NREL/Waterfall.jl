mutable struct Blending
    point1::Point
    point2::Point
    color1::Coloring
    color2::Coloring
end

function Blending(x::T; kwargs...) where T <: Points
    color1 = Coloring(x; kwargs...)
    color2 = Coloring(x; saturation=-0.5, kwargs...)

    xmid = getindex.([midpoint(x...) for x in x.points],1)

    y1 = minimum(getindex.(getindex.(x.points,1),2))
    y2 = maximum(getindex.(getindex.(x.points,2),2))

    return Blending.(Point.(0, 0), Point.(WIDTH, y2), color1, color2)

    # return Blending.(Point.(0, y1), Point.(0, y2), color1, color2)
    # return Blending.(Point.(xmid, y1), Point.(xmid, y2), color1, color2)
end