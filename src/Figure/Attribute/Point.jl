mutable struct Point <: Attribute
    formatting::Union{Blending,Coloring}
    style::Symbol
    diameter::Float64
end