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


mutable struct Label
    text::String
    scale::Float64
    position::Luxor.Point
    halign::Symbol
    valign::Symbol
    angle::Float64
end

function Label( ; text, scale, position, halign, valign, angle)
    return Label( ; text, scale, position, halign, valign, angle)
end
