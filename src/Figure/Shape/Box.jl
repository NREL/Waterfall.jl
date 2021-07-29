mutable struct Box <: Shape
    position::Tuple{Luxor.Point,Luxor.Point}
    color::Union{Blending,Coloring}
    style::Union{Symbol, Vector{Float64}}
end

function Box( ; position, color, style=:fill, kwargs...)
    return Box(position, color, style)
end