mutable struct Point <: Shape
    position::Luxor.Point
    color::Union{Blending,Coloring}
    size::Float64
end


function Point( ; position, color, size, kwargs...)
    return Point(position, color, size)
end