mutable struct Blending
    point1::Point
    point2::Point
    color1::Coloring
    color2::Coloring
end


function Blending(x::T; kwargs...) where T <: Geometry
    color1 = Coloring(x; saturation=-0.2, kwargs...)
    color2 = Coloring(x; saturation=-0.7, kwargs...)

    xmid = getindex.([midpoint(x...) for x in x.points],1)

    y1 = minimum(getindex.(getindex.(x.points,1),2))
    y2 = maximum(getindex.(getindex.(x.points,2),2))
    
    return Blending.(Point.(xmid, y1), Point.(xmid, y2), color1, color2)
end