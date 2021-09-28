mutable struct Line <: Shape
    position::Tuple{Luxor.Point,Luxor.Point}
    color::Union{Blending,Coloring}
    style::Union{Symbol, Vector{Float64}}
end

function Line( ; position, color, style=:stroke, kwargs...)
    return Line(position, color, style)
end