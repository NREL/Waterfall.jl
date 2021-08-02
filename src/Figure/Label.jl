mutable struct Label
    text::Vector{String}
    textsize::Float64
    width::Float64
    position::Luxor.Point
    alignment::Symbol
end