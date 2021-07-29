mutable struct Point <: Shape
    points::Luxor.Point
    color::Union{Blending,Coloring}
    alpha::Float64
    size::Float64
end

function Point( ; points, color, alpha, size=10.0, kwargs...)
    return Point(points, color, alpha, size)
end