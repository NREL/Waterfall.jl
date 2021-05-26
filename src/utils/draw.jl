set_formatting(c::Coloring) = Luxor.setcolor(c.hue.r, c.hue.g, c.hue.b, c.opacity)
set_formatting(b::Blending) = Luxor.setblend(Luxor.blend(b.point1, b.point2, b.color1.hue, b.color2.hue))

"""
    draw_box(point::Tuple{Luxor.Point,Luxor.Point})
This function draws a box with corners (`point[1], point[2]`).

# Keyword Argument:
- `style::Symbol=:fill`
"""
draw_box(point::Tuple; style=:fill, kwargs...) = Luxor.box(point[1], point[2], style)
draw_box(args...; kwargs...) = _draw(draw_box, args...; kwargs...)


"""
    draw_line(point::Tuple{Luxor.Point,Luxor.Point})
This function draws a Luxor.line from `point[1]` to `point[2]`.

# Keyword Argument:
- `style::Symbol=:stroke`
"""
draw_line(point::Tuple; style=:stroke, kwargs...) = Luxor.line(point[1], point[2], style)
draw_line(args...; kwargs...) = _draw(draw_line, args...; kwargs...)


"""
    draw_point(point::Tuple{Luxor.Point,Luxor.Point})
This function draws a point at

# Keyword Arguments:
- `diameter=1`
- `style::Symbol=:fill`
"""
draw_point(point::Luxor.Point; diameter=1, style=:fill, kwargs...) = Luxor.circle(point, diameter, style)
draw_point(args...; kwargs...) = _draw(draw_point, args...; kwargs...)

draw_poly(point::Vector{Luxor.Point}; style=:fill, kwargs...) = Luxor.poly(point, close=true, style)
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
    kwargs...) where T<:Geometry
    return fun(x.points, formatting(x; kwargs...), args...; kwargs...)
end

"""
    draw(p::Plot{T}, args...; kwargs...) where T<:Geometry
This method adds to a `Luxor.Drawing`: the plot title, x- and y-axes, and waterfall cascade
of the geometry consistent with `T` and stored in `p.cascade`.

    draw(cascade::Cascade{T}, args...; kwargs...) where T<:Geometry
This method adds to a `Luxor.Drawing` the entire cascade of waterfalls.

    draw(x::T, args...; kwargs...) where T<:Geometry
This method adds to a `Luxor.Drawing` each waterfall in the cascade.
"""
function draw(p::Plot, args...; distribution, samples, kwargs...)
    _draw_title(
        titlecase("$distribution Distribution"),
        "N = $(length(p))",
    )
    _draw_xaxis(p.xaxis)
    _draw_yaxis(p.yaxis)
    draw(p.cascade, args...; kwargs...)
    return nothing
end


function draw(x::Cascade{T}, args...; kwargs...) where T <: Geometry
    draw(x, T==Parallel, args...; kwargs...)
    return nothing
end


function draw(x::Cascade{T}, steps_only::Bool, args...; kwargs...) where T <: Geometry
    draw(x.steps, args...; kwargs...)

    if !steps_only
        draw(x.start, args...; hue="black", kwargs...)
        draw(x.stop, args...; hue="black", kwargs...)
    end
end


draw(vec::Vector, args...; kwargs...) = [draw(x, args...; kwargs...) for x in vec]


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


function _draw_yaxis(ax::Axis; halign=:right, valign=:middle)
    # Draw axis Luxor.line.
    Luxor.arrow(Luxor.Point(0,HEIGHT), Luxor.Point(0,0))

    # Draw ticks.
    N = length(ax.ticks)
    for ii in 1:length(ax.ticks)
        ii>1 && Luxor.line(Luxor.Point(-SEP/2, ax.ticks[ii]), Luxor.Point(SEP/2, ax.ticks[ii]), :stroke)
        Luxor.text(
            string(Integer(ax.ticklabels[ii])),
            Luxor.Point(-SEP, ax.ticks[ii]),
            halign=halign,
            valign=valign,
        )
    end

    # Add label.
    Luxor.text(ax.label,
        Luxor.midpoint(Luxor.Point(-LEFT_BORDER, HEIGHT), Luxor.Point(-SEP, 0)),
        angle=-pi/2,
        halign=:center,
        valign=:bottom,
    )
end

function _draw_xaxis(ax::Axis; angle=-pi/4, halign=:right, valign=:top)
    # Draw axis Luxor.line.
    Luxor.arrow(Luxor.Point(0,HEIGHT), Luxor.Point(WIDTH+2*SEP,HEIGHT))

    # Draw ticks.
    for ii in 1:length(ax.ticks)
        Luxor.line(Luxor.Point(ax.ticks[ii], HEIGHT-SEP/2), Luxor.Point(ax.ticks[ii], HEIGHT+SEP/2), :stroke)
        Luxor.text(
            ax.ticklabels[ii],
            Luxor.Point(ax.ticks[ii], HEIGHT+SEP),
            angle=angle,
            halign=halign,
            valign=valign,
        )
    end
end


function _draw_title(str::String)
    Luxor.text(str, Luxor.Point(WIDTH/2, SEP), halign=:center, valign=:top)
    return nothing
end

function _draw_title(str...)
    y0 = SEP
    fonttmp = Luxor.get_fontsize()
    dy = 1.25*fonttmp
    Luxor.fontsize(dy)
    for ii in 1:length(str)
        Luxor.text(str[ii], Luxor.Point(WIDTH/2, y0+dy*(ii-1)), halign=:center, valign=:top)
    end
    Luxor.fontsize(fonttmp)
    return nothing
end


function _draw_highlight(p::Plot{Data}, highlights::Vector;
    style=:stroke,
    opacity=1.0,
    hue="black",
    width=1,
)
    if !isempty(highlights)
        # Define Luxor.line styles.
        dashes = scale_dash.(highlights)
        Luxor.setline(width)

        # Define dimensions.
        hfont = Luxor.get_fontsize()
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

            Luxor.setcolor(Luxor.sethue(hue)..., opacity)
            Luxor.box(Luxor.Point(x[4],y-hbox), Luxor.Point(x[2],y+hbox), style)
            Luxor.text(_label_stat(highlights[kk]), Luxor.Point(x[1],y); halign=:left, valign=:middle)
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