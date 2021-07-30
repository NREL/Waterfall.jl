"""
    set(color::Coloring)
"""
function set(color::Coloring)
    Luxor.setcolor(Luxor.sethue(color.hue)..., color.alpha)
    return nothing
end


"""
    draw(attr::Box)
This function draws the input
"""
function draw(plot::T) where T <: Plot
    draw(plot.cascade)

    Luxor.setcolor(Luxor.sethue("black")..., 1.0)
    _draw_title(plot)
    draw(plot.axes)
    
    return nothing
end


function draw(shape::Box)
    set(shape.color)
    Luxor.box(shape.position..., shape.style)
    return nothing
end


function draw(shape::Line)
    println("line")
    # set(shape.color)
    Luxor.line(shape.position[1], shape.position[2], shape.style)
    return nothing
end


function draw(ax::T) where T <: Axis
    _draw(typeof(ax))
    _draw_ticks(ax)
    # T==YAxis && _draw_ticklabels(ax)
    _draw_ticklabels(ax)
end


draw(x::Cascade{T}) where T<:Geometry = draw(collect_data(x))
draw(x::T) where T<:Geometry = draw(getproperty(x, :attribute))
draw(lst::AbstractArray) = [draw(x) for x in lst]


"""
"""
function _draw_title(plot::T) where T <: Plot
    _draw_label("N = $(length(plot))", Luxor.Point(WIDTH/2, 0); valign=:top)
    return nothing
end


"""
    _draw(XAxis)
    _draw(YAxis)
This function draws an arrow for the input axis.
"""
_draw(::Type{XAxis}) = Luxor.arrow(Luxor.Point.((0,WIDTH+2*SEP), HEIGHT)...)
_draw(::Type{YAxis}) = Luxor.arrow(Luxor.Point.(0, (HEIGHT,0))...)


"""
"""
_draw_tick(points) = Luxor.line(points..., :stroke)


"""
"""
_draw_ticks(ax::YAxis) = _draw_tick.(_define_ytick.(ax.ticks))
# _draw_ticks(ax::XAxis) = _draw_tick.(_define_xtick.(ax.ticks))
_draw_ticks(ax::XAxis) = nothing


"""
"""
_define_xtick(x; y=HEIGHT) = Luxor.Point.(x, _extend_by(y))
_define_ytick(y; x=0) = Luxor.Point.(_extend_by(x), y)


"""
"""
_extend_by(x, sep=SEP) = (-1,1).*0.5.*sep .+ x


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


"""
    _draw_ticklabels(ax::T) where T <: Axis
"""
function _draw_ticklabels(ax::XAxis; y=HEIGHT+SEP)
    lab = ax.ticklabels
    x = ax.ticks
    _draw_label.(ax.ticklabels, Luxor.Point.(x, y); valign=:top, halign=:center)

    Luxor.fontsize(10.2)
    # _draw_label.(ax.ticksublabels, Luxor.Point.(x, y+SEP); valign=:top, halign=:right, angle=-pi/6)

    N = length(ax.ticksublabels)
    x = cumulative_x( ; steps=N)

    for ii in 1:N
        str = Luxor.textlines(ax.ticksublabels[ii], width(N))
        str = str[.!isempty.(str)]

        Luxor.textbox(str, Luxor.Point(x[ii], y+1.5*SEP); leading=0, alignment=:center)
        # textbox(lines::Array, pos::Point=O;
        #     leading = 12,
        #     linefunc::Function = (linenumber, linetext, startpos, height) -> (),
        #     alignment=:left)
    end

    Luxor.fontsize(14)
    return nothing
end

function _draw_ticklabels(ax::YAxis; x=0-SEP)
    lab = ax.ticklabels
    y = ax.ticks
    _draw_label.(lab, Luxor.Point.(x, y); valign=:middle, halign=:right)
    return nothing
end