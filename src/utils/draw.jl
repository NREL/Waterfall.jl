function draw(point::Point, c::Coloring; diameter=1, style=:fill, kwargs...)
    setcolor(c.hue.r, c.hue.g, c.hue.b, c.opacity)
    return Luxor.circle(point, diameter, style)
end


function draw(point::Tuple{Point,Point}, b::Blending; style=:fill, kwargs...)
    setblend(blend(b.point1, b.point2, b.color1.hue, b.color2.hue))
    return Luxor.box(point[1], point[2], style)
end


function draw(point::Tuple{Point,Point}, c::Coloring; style=:fill, kwargs...)
    setcolor(c.hue.r, c.hue.g, c.hue.b, c.opacity)
    return Luxor.box(point[1], point[2], style)
end


function draw(point::Vector{Point}, c::Coloring; style=:fill, kwargs...)
    setcolor(c.hue.r, c.hue.g, c.hue.b, c.opacity)
    return poly(point, close=true, style)
end


function draw(x::Vertical, args...; kwargs...)
    [draw(p, b) for (p, b) in zip(x.points, Blending(x; kwargs...))]
    return nothing
end


function draw(x::Horizontal, ff; opacity=missing, kwargs...)
    ismissing(opacity) && (opacity = 0.25/log(length(x)))
    coloring = Coloring(x; opacity=opacity, kwargs...)

    [draw(x.points[ii], coloring[ii]) for ii in 1:ff]

    # coloring = Coloring(x; opacity=1.0, kwargs...)
    # draw(x.points[ff], coloring[ff])

    # [draw(p, c; kwargs...) for (p, c) in zip(x.points, coloring)]
    return nothing
end


function draw(x::Horizontal; opacity=missing, kwargs...)
    ismissing(opacity) && (opacity = 0.25/log(length(x)))
    coloring = Coloring(x; opacity=opacity, kwargs...)
    [draw(p, c; kwargs...) for (p, c) in zip(x.points, coloring)]
    return nothing
end


function draw(x::Scatter, args...; kwargs...)
    [draw(p, c) for (p, c) in zip(x.points, Coloring(x; kwargs...))]
    return nothing
end


function draw(x::Violin, args...; kwargs...)
    coloring = Coloring(x; opacity=0.5, kwargs...)[1]
    draw(x.points, coloring; kwargs...)
    return nothing
end


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