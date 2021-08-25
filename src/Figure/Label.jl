mutable struct Label
    text::Vector{String}
    scale::Float64
    position::Luxor.Point
    alignment::Symbol
    leading::Float64
end

Label( ; text, scale, position, alignment, leading) = Label( ; text, scale, position, alignment, leading)