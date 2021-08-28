"""
    set(x::Coloring)
    set(x::Blending)
These methods set the color or blend defined in `x`.
"""
set(color::Coloring) = Luxor.setcolor(Luxor.sethue(color.hue)..., color.alpha)
set(color::Blending) = Luxor.setblend(Luxor.blend(color.direction..., color.hue...))


"""
    draw(plot::Plot{T}) where T<:Geometry
These methods draw a waterfall plot using all of the styling and values stored in `plot`.
"""
function draw(shape::T) where T <: Shape
    set(shape.color)
    _draw(shape)
    return nothing
end


function draw(lab::T) where T <: Label
    Luxor.fontsize(lab.scale * FONTSIZE)
    Luxor.setcolor(Luxor.sethue("black")...)
    _draw(lab)

    Luxor.fontsize(FONTSIZE)
    return nothing
end


draw(x::T; kwargs...) where T<:Plot = draw(collect(values(x)))
draw(x::Cascade{T}) where T<:Geometry = draw(collect_data(x))
draw(x::T) where T<:Geometry = draw(x.shape)
draw(x::T) where T<:Axis = draw(collect(values(x)))
draw(x::String) = nothing

draw(lst::AbstractArray) = [draw(x) for x in lst]


"""
    _draw(lab::T) where T <: Label
    _draw(shape::T) where T <: Shape
These are helper methods for drawing different types of labels and shapes. They do not
include steps like setting colors and font size, since these processes are consistent across
`Label` and `Shape`. 
"""
function _draw(lab::Label{String})
    Luxor.text(lab.text, lab.position; halign=lab.halign, valign=lab.valign, angle=lab.angle)
    return nothing
end

function _draw(lab::Label{Vector{String}})
    Luxor.textbox(lab.text, lab.position;
        alignment = lab.halign,
        leading = lab.leading*lab.scale*FONTSIZE,
    )
    return nothing
end

_draw(lab::Label{Missing}) = nothing

_draw(shape::Arrow) = Luxor.arrow(shape.position..., linewidth=2.0)
_draw(shape::Box) = Luxor.box(shape.position..., shape.style)
_draw(shape::Line) = Luxor.line(shape.position..., shape.style)
_draw(shape::Poly) = Luxor.poly(shape.position, close=true, shape.style)


"""
    _draw_legend()
"""
function _draw_legend()
    Luxor.text("mean", Luxor.Point(WIDTH-5*SEP,5*SEP); halign=:left, valign=:middle)
    draw(Box(
        (Luxor.Point(WIDTH-7.5*SEP,4.5*SEP),Luxor.Point(WIDTH-5.5*SEP,5.5*SEP)),
        _define_from(Coloring, "black"),
        :stroke,
    ))
    return nothing
end


"""
"""
function padding(ax::XAxis)
    lab = ax.ticksublabels
    lines = maximum(length.(getfield.(lab,:text)))
    return lines * FONTSIZE
end