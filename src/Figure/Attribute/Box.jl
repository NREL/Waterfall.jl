mutable struct Box <: Attribute
    formatting::Union{Blending,Coloring}
    style::Symbol
    dash::Vector
end