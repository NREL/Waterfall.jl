function getindex!(cascade, rng)
    data = collect_data(cascade)
    value = getindex.(get_value.(data), Ref(rng))
    set_value!.(data, value)
    return cascade
end



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

# Draw some type values.
draw(x::Cascade{T}) where T<:Geometry = draw(collect_data(x))
draw(x::T) where T<:Geometry = draw(x.shape)

# Draw all Type values
draw(x::T; kwargs...) where T<:Plot = _draw(x)
draw(x::T) where T<:Axis = _draw(x)
draw(x::Annotation) = _draw(x)
draw(x::Handle) = _draw(x)
draw(x::String) = nothing
draw(x::Missing) = nothing

draw(lst::AbstractArray) = [draw(x) for x in lst]
draw(pair::Pair) = draw(collect(pair))


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
    if !all(isempty.(lab.text))
        Luxor.textbox(lab.text, lab.position;
            alignment = lab.halign,
            leading = lab.leading*lab.scale*FONTSIZE,
        )
    end
    return nothing
end

# _draw(lab::Label{Missing}) = nothing

# Draw shapes.
_draw(shape::Arrow) = Luxor.arrow(shape.position..., linewidth=2.0)
_draw(shape::Box) = Luxor.box(shape.position..., shape.style)
_draw(shape::Line) = Luxor.line(shape.position..., shape.style)
_draw(shape::Poly) = Luxor.poly(shape.position, close=true, shape.style)

# Draw all Type values.
_draw(x::Any) = draw(collect(values(x)))


"""
"""
function animate(x::T, N; kwargs...) where T<:Plot
    _animate(x, N)
    # x.path = _title_animation_step(x.path, N)
    return nothing
end

function animate(x::Cascade{T}, N) where T<:Geometry
    println("drawing cascade")
    data = collect_data(x)
    shapes = getindex.(getproperty.(data,:shape), Ref(1:N))
    draw(shapes)
    return nothing
end

animate(lst::Vector, N) = [animate(x,N) for x in lst]
animate(x, N) = draw(x)


_animate(x::Any, N) = animate(collect(values(x)), N)



function _title_animation_step(x::String, N)
    m = match(Regex("(.*\\_n)(\\d*)(.*)"), x)
    step = join([
        m[2],
        Printf.@sprintf("%09.0f", N)[end-(length(m[2])-1):end],
    ], "-")
    return m[1] * step * m[3]
end


"""
"""
function height(lab::Vector{T}) where T<:Label
    result = maxlines(lab) * FONTSIZE * lab[1].scale * lab[1].leading
    return convert(Int, ceil(result))
end

height(ax::XAxis) = height(ax.ticklabels) + height(ax.ticksublabels)
height(plot::Plot) = height(plot.axes[1])


"""

"""
maxlines(lab::Vector{Label{Vector{String}}}) = maximum(length.(getfield.(lab,:text)))
maxlines(lab::Vector{Label{String}}) = 1