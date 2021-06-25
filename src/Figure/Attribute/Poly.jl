mutable struct Poly <: Attribute
    formatting::Union{Blending,Coloring}
    style::Symbol
    dash::Vector
end