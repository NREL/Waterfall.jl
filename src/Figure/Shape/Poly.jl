mutable struct Poly <: Shape
    position::Vector{Luxor.Point}
    color::Union{Blending,Coloring}
    style::Union{Symbol, Vector{Float64}}
end

function Poly( ; position, color, style=:fill, kwargs...)
    return Poly(position, color, style)
end