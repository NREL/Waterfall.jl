mutable struct Label5{T <: Union{Missing,String,Vector{String}}}
    text::T
    scale::Float64
    position::Luxor.Point
    halign::Symbol
    valign::Symbol
    angle::Float64
    leading::Float64
end


function Label5( ;
    text,
    scale::Real,
    position,
    halign,
    valign,
    angle::Real,
    leading::Real,
)
    return Label5(
        text,
        convert(Float64, scale),
        position,
        halign,
        valign,
        convert(Float64, angle),
        convert(Float64, leading),
    )
end

labstr = Label5( ; text="hieeeee", scale=1.1, position=Luxor.Point(0,10), halign=:center, valign=:middle, angle=0.0, leading=0)