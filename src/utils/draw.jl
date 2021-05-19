set_formatting(c::Coloring) = setcolor(c.hue.r, c.hue.g, c.hue.b, c.opacity)
set_formatting(b::Blending) = setblend(blend(b.point1, b.point2, b.color1.hue, b.color2.hue))


draw_box(point::Tuple; style=:fill, kwargs...) = Luxor.box(point[1], point[2], style)
draw_box(args...; kwargs...) = _draw(draw_box, args...; kwargs...)

draw_line(point::Tuple; kwargs...) = Luxor.line(point[1], point[2], :stroke)
draw_line(args...; kwargs...) = _draw(draw_line, args...; kwargs...)

draw_point(point::Point; diameter=1, style=:fill, kwargs...) = Luxor.circle(point, diameter, style)
draw_point(args...; kwargs...) = _draw(draw_point, args...; kwargs...)

draw_poly(point::Vector{Point}; style=:fill, kwargs...) = Luxor.poly(point, close=true, style)
draw_poly(args...; kwargs...) = _draw(draw_poly, args...; kwargs...)



function _draw(fun, point, format::Union{Coloring,Blending}; kwargs...)
    set_formatting(format)
    fun(point; kwargs...)
    return nothing
end

function _draw(fun, point, format::AbstractArray, N::Integer; kwargs...)
    [fun(point[ii], format[ii]; kwargs...) for ii in 1:N]
    return nothing
end

function _draw(fun, point, format::AbstractArray; kwargs...)
    return _draw(fun, point, format, length(format); kwargs...)
end




function _draw_with(x::T, fun::Function, formatting::DataType, args...;
    kwargs...) where T<:Points
    return fun(x.points, formatting(x; kwargs...), args...; kwargs...)
end



function draw(x::Vertical, args...; kwargs...)
    return _draw_with(x, draw_box, Blending, args...; kwargs...)
end

function draw(x::Horizontal, args...; kwargs...)
    return _draw_with(x, draw_box, Coloring, args...; kwargs...)
end

function draw(x::Parallel, args...; opacity=0.5, kwargs...)
    return _draw_with(x, draw_line, Coloring, args...; opacity=opacity, kwargs...)
end


# function draw(x::Scatter, args...; kwargs...)
#     [draw_point(p, c) for (p, c) in zip(x.points, Coloring(x; kwargs...))]
#     return nothing
# end


# function draw(x::Violin, args...; kwargs...)
#     coloring = Coloring(x; opacity=0.5, kwargs...)[1]
#     draw_poly(x.points, coloring; kwargs...)
#     return nothing
# end


function draw(x::Cascade{T}, args...; kwargs...) where T <: Points
    draw(x.start, args...; hue="black", kwargs...)
    draw(x.stop, args...; hue="black", kwargs...)
    [draw(x.steps[ii], args...; kwargs...) for ii in 1:length(x.steps)]
    return nothing
end


function draw(p::Plot, args...; kwargs...)
    _draw_xaxis(p.xaxis)
    _draw_yaxis(p.yaxis)
    draw(p.cascade, args...; kwargs...)
    return nothing
end

function draw(p::SplitPlot; kwargs...)
    _draw_xaxis(p.xaxis)
    _draw_yaxis(p.yaxis)

    draw(p.beginning; kwargs...)
    draw(p.ending; kwargs...)
    return nothing
end


function _draw_yaxis(ax::Axis; halign=:right, valign=:middle)
    # Draw axis line.
    arrow(Point(0,HEIGHT), Point(0,0))

    # Draw ticks.
    N = length(ax.ticks)
    for ii in 1:length(ax.ticks)
        ii>1 && line(Point(-SEP/2, ax.ticks[ii]), Point(SEP/2, ax.ticks[ii]), :stroke)
        text(
            string(Integer(ax.ticklabels[ii])),
            Point(-SEP, ax.ticks[ii]),
            halign=halign,
            valign=valign,
        )
    end

    # Add label.
    text(ax.label,
        midpoint(Point(-LEFT_BORDER, HEIGHT), Point(-SEP, 0)),
        angle=-pi/2,
        halign=:center,
        valign=:bottom,
    )
end

function _draw_xaxis(ax::Axis; angle=-pi/4, halign=:right, valign=:top)
    # Draw axis line.
    arrow(Point(0,HEIGHT), Point(WIDTH+2*SEP,HEIGHT))

    # Draw ticks.
    for ii in 1:length(ax.ticks)
        line(Point(ax.ticks[ii], HEIGHT-SEP/2), Point(ax.ticks[ii], HEIGHT+SEP/2), :stroke)
        text(
            ax.ticklabels[ii],
            Point(ax.ticks[ii], HEIGHT+SEP),
            angle=angle,
            halign=halign,
            valign=valign,
        )
    end
end


function _draw_title(str::String)
    text(str, Point(WIDTH/2, SEP), halign=:center, valign=:top)
    return nothing
end

function _draw_title(str...)
    y0 = SEP
    dy = get_fontsize()
    for ii in 1:length(str)
        text(str[ii], Point(WIDTH/2, y0+dy*(ii-1)), halign=:center, valign=:top)
    end
    return nothing
end


# function _draw_legend()
#     y0 = SEP*3
# end

# _legend_highlight(stat::String, hue; style=:stroke)
# draw(highlight(pdata, hl).cascade; hue=hue, style=:stroke, opacity=1.0)