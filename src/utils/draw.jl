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
    draw(ax.ticklabels)
    draw(ax.ticks.shape)
    Luxor.arrow(ax.ticks.arrow...)
    return nothing
end


draw(lst::AbstractArray) = [draw(x) for x in lst]
draw(x::Cascade{T}) where T<:Geometry = draw(collect_data(x))

function draw(x::T) where T<:Geometry
    draw(x.shape)
    draw(x.annotation)
    return nothing
end


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
    _draw_label(label, point; kwargs)
This method adds the text in `label` to the point `point`.

    _draw_label(label, point1, point2; kwargs)
This method adds the text in `label` to the midpoint between `point1` and `point2`.

# Keywords
- `halign::Symbol=:center`
- `valign::Symbol=:bottom`
"""
function _draw_label(label::String, point::Luxor.Point; halign=:center, valign=:bottom, kwargs...)
    Luxor.text(label, point; halign=halign, valign=valign, kwargs...)
    return nothing
end

function _draw_label(label::String, point1::Luxor.Point, point2::Luxor.Point; kwargs...)
    _draw_label(label, Luxor.midpoint(point1, point2); kwargs...)
    return nothing
end

function _draw_label(label::Float64, args...; kwargs...)
    _draw_label(Printf.@sprintf("%0.1f", label), args...; kwargs...)
    return nothing
end


function _draw_label(ax::YAxis; angle=-pi/2, x=-(LEFT_BORDER-0.5*SEP))
    _draw_label(
        uppercase(ax.label),
        Luxor.midpoint(Luxor.Point(x,ax.ticks[2]), Luxor.Point(x,ax.ticks[end]));
        angle=angle,
        valign=:top,
        halign=:center,
        # kwargs...,
    )
end


function draw(lab::Label)
    tmp = Luxor.get_fontsize()
    font = tmp * lab.scale
    Luxor.fontsize(font)

    Luxor.setcolor(Luxor.sethue("black")...)
    Luxor.textbox(lab.text, lab.position; alignment=lab.alignment, leading=lab.leading*font)
    Luxor.fontsize(tmp)
    return nothing
end


draw(x::Missing) = nothing


function padding(ax::XAxis)
    lab = ax.ticksublabels
    lines = maximum(length.(getfield.(lab,:text)))
    return lines * FONTSIZE
end