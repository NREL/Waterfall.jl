mutable struct Arrow <: Shape
    position::Tuple{Luxor.Point,Luxor.Point}
    color::Union{Blending,Coloring}
    style::Union{Symbol, Vector{Float64}}
end

function Arrow( ; position, color, style)
    return Arrow(position, color, style)
end