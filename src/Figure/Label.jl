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


# mutable struct Label
#     text::Vector{String}
#     scale::Float64
#     position::Luxor.Point
#     alignment::Symbol
#     leading::Float64
# end

# Label( ; text, scale, position, alignment, leading) = Label( ; text, scale, position, alignment, leading)