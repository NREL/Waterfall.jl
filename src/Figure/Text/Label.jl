mutable struct Label{T <: Union{String,Vector{String}}}
    text::T
    scale::Float64
    position::Luxor.Point
    halign::Symbol
    valign::Symbol
    angle::Float64
    leading::Float64
end


function Label( ;
    text,
    scale::Real,
    position,
    halign,
    valign,
    angle::Real,
    leading::Real,
)
    return Label(
        text,
        convert(Float64, scale),
        position,
        halign,
        valign,
        convert(Float64, angle),
        convert(Float64, leading),
    )
end

# labstr = Label( ; text="hieeeee", scale=1.1, position=Luxor.Point(0,10), halign=:center, valign=:middle, angle=0.0, leading=0)
# labvec = Label( ; text=["hieeeee","leoooooo"], scale=1.1, position=Luxor.Point(0,10), halign=:center, valign=:middle, angle=0.0, leading=0)
# labmis = Label( ; text=missing, scale=1.1, position=Luxor.Point(0,10), halign=:center, valign=:middle, angle=0.0, leading=0)