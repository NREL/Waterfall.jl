"""
    set(color::Coloring)
"""
function set(color::Coloring)
    Luxor.setcolor(Luxor.sethue(color.hue)..., color.alpha)
    return nothing
end

function set(color::Blending)
    Luxor.setblend(Luxor.blend(color.direction..., color.hue...))
    return nothing
end


"""
    draw(attr::Box)
This function draws the input
"""
function draw(plot::T; kwargs...) where T <: Plot
    draw(plot.cascade)

    Luxor.setcolor(Luxor.sethue("black")..., 1.0)
    draw(plot.title)
    draw(plot.axes)
    
    return nothing
end


function draw(shape::Box)
    set(shape.color)
    Luxor.box(shape.position..., shape.style)
    return nothing
end


function draw(shape::Line)
    set(shape.color)
    Luxor.line(shape.position[1], shape.position[2], shape.style)
    return nothing
end


function draw(shape::Poly)
    set(shape.color)
    Luxor.poly(shape.position, close=true, shape.style)
    return nothing
end


function draw(ax::XAxis)
    draw(ax.ticklabels)
    draw(ax.ticksublabels)
    Luxor.arrow(ax.ticks.arrow...)
    return nothing
end


function draw(ax::YAxis)
    draw(ax.label)
    draw(ax.ticklabels)
    draw(ax.ticks.shape)
    Luxor.arrow(ax.ticks.arrow...)
    return nothing
end


function draw(lab::T) where T <: Label
    Luxor.fontsize(lab.scale * FONTSIZE)
    Luxor.setcolor(Luxor.sethue("black")...)

    _draw(lab)

    Luxor.fontsize(FONTSIZE)
    return nothing
end


draw(lst::AbstractArray) = [draw(x) for x in lst]
draw(x::Cascade{T}) where T<:Geometry = draw(collect_data(x))

function draw(x::T) where T<:Geometry
    draw(x.shape)
    # draw(x.annotation)
    return nothing
end


"""
    _draw(lab::T) where T <: Label
This is a helper function for drawing different types of labels.
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


"""
"""
function _draw_title(plot::T; interactivity, fuzziness, kwargs...) where T <: Plot
    N = length(plot)
    idx = [true, plot.cascade.iscorrelated, N>1]

    str = [
        "$N SAMPLE" * (N>1 ? "S" : ""),
        "CORRELATION COEFFICIENT: min=$(interactivity[1]), max=$(interactivity[2])",
        "UNIFORM SAMPLE DISTRIBUTION: f(x; a>$(fuzziness[1]), b<$(fuzziness[2]))"
    ][idx]

    font = Luxor.get_fontsize()
    Luxor.textbox(str, Luxor.Point(WIDTH/2, -TOP_BORDER); leading=0, alignment=:center)
    return nothing
end


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