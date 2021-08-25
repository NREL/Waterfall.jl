mutable struct Labelbox
    text::Vector{String}
    scale::Float64
    position::Luxor.Point
    alignment::Symbol
    leading::Float64
end

function Labelbox( ; text, scale, position, alignment, leading)
    return Labelbox( ; text, scale, position, alignment, leading)
end