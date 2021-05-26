mutable struct Attributes
    color::Union{Blending,Coloring}
    shape::Symbol
    style::Symbol
    dash::Vector
end

Attributes( ; color, shape, style, dash) = Attributes( ; color, shape, style, dash)