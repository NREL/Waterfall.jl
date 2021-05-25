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

function draw(x::Parallel, args...; kwargs...)
    return _draw_with(x, draw_line, Coloring, args...; factor=1.0, kwargs...)
end

function draw(x::Violin, args...; kwargs...)
    return _draw_with(x, draw_poly, Coloring, args...; opacity=0.5, kwargs...)
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


function draw(x::Cascade{T}, args...; show_stc::Bool=true, kwargs...) where T <: Points
    if show_stc
        draw(x.start, args...; hue="black", kwargs...)
        draw(x.stop, args...; hue="black", kwargs...)
    end
    [draw(x.steps[ii], args...; kwargs...) for ii in 1:length(x.steps)]
    return nothing
end


function draw(p::Plot, args...; distribution, samples, kwargs...)
    _draw_title(
        titlecase("$distribution Distribution"),
        "N = $samples",
    )
    _draw_xaxis(p.xaxis)
    _draw_yaxis(p.yaxis)
    draw(p.cascade, args...; kwargs...)
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
    fonttmp = get_fontsize()
    dy = 1.25*fonttmp
    fontsize(dy)
    for ii in 1:length(str)
        text(str[ii], Point(WIDTH/2, y0+dy*(ii-1)), halign=:center, valign=:top)
    end
    fontsize(fonttmp)
    return nothing
end


function _draw_highlight(p::Plot{Data}, highlights::Vector;
    style=:stroke,
    opacity=1.0,
    hue="black",
    width=1,
)
    if !isempty(highlights)
        # Define line styles.
        dashes = scale_dash.(highlights)
        setline(width)

        # Define dimensions.
        hfont = get_fontsize()
        y0 = 2*hfont + SEP
        dy = 1.5*hfont
        hbox = 0.5*hfont
        
        x0 = 0.8*WIDTH
        wbox = 1*SEP

        for kk in 1:length(highlights)
            Luxor.setdash(dashes[kk])
            
            # Add boxes to plot.
            draw(highlight(p, highlights[kk]).cascade; hue=hue, style=style, opacity=opacity)

            # Define legend positions.
            y = y0+dy*(kk+1)                    # middle
            x = [x0-wbox*(ii-1) for ii in 1:4]  # box (left,mid,right); label (left)

            setcolor(sethue(hue)..., opacity)
            Luxor.box(Point(x[4],y-hbox), Point(x[2],y+hbox), style)
            Luxor.text(_label_stat(highlights[kk]), Point(x[1],y); halign=:left, valign=:middle)
        end
    end

    return nothing
end



function scale_dash(p::Real; dmin=0.5, factor=10)
    if p==1.0
        result = "solid"
    else
        dash = (1-dmin)*p + dmin
        result = factor*[dash, 1-dash]
    end
    
    return result
end

scale_dash(str::String) = scale_dash(1.0)
scale_dash(tup::Tuple{String,T}; kwargs...) where T<:Real = scale_dash(tup[2]; kwargs...)