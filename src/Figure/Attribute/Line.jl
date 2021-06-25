mutable struct Line <: Attribute
    formatting::Union{Blending,Coloring}
    style::Symbol
    dash::Vector
end