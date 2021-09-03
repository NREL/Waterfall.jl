include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

colorcycle = false

locals = (
    nsample = 3,
    permutation = perm,
    permute = true,
    ncor = true,
    correlate = true,
    colorcycle = false,
    ylabel = "Efficiency (%)",
    vmin = 12.0,
);

fun = Statistics.mean
args = (fun,)
cascade = define_from(Cascade{Data}, df; locals..., kwargs...)

# pos = scale_for(cascade, Geometry, args...; kwargs...)
# # all(length.(pos).==1) && (pos = getindex.(pos,1))

# sgn = sign(cascade)
# sgn[3][2] = -sgn[3][2]

# label = get_label.(collect_data(cascade))
# shape = _define_from(Box, Coloring, pos, sgn; style=:fill, kwargs...)


# ensurearray(x::AbstractArray) = x
# ensurearray(x) = [x;]


# annot = _define_annotation(cascade, Horizontal, Statistics.mean; locals..., kwargs...)
# cas = set_geometry(cascade, Horizontal, Statistics.mean; locals..., kwargs..., style=:stroke, alpha=1.0)
mutable struct Handle
    label::AbstractArray
    series::AbstractArray
end

mutable struct Legend
    handle::Vector{Handle}
end

Legend( ; handle) = Legend(handle)



# 
#       TO-DO:
# 
# Differentiate between blending/two labels and coloring/one label
# Make this possible: _define_from(Blending, [-1.,+1])


# function _define_from(::Type{Handle}, cascade::Cascade{T}; colorcycle, kwargs...) where T <: Geometry
# end

function _define_from(::Type{Handle}, cascade::Cascade{Data}, fun::Function, args...;
    x0 = WIDTH-100,
    y0 = 3*SEP,
    dx = 2*SEP,
    dy = SEP,
    space = SEP,
    idx = 1,
    kwargs...,
)
    label = _define_annotation(cascade, Horizontal, fun, args...; kwargs..., scale=0.9)
    cas = set_geometry(cascade, Horizontal, fun, args...; kwargs..., style=:stroke, alpha=1.0)

    # Need to update position.
    y0 = y0 + FONTSIZE*(idx-1)
    shape = first(cas.start.shape)
    setproperty!(shape, :position, (Luxor.Point(x0-dx, y0-dy), Luxor.Point(x0+dx,y0+dy)))

    description =_define_from(Label, string(fun), Luxor.Point(x0+dx+space, y0); halign=:left)

    return Handle([label, cas], [shape, description])
end


"""
This function defines the information required for a 
"""
function _define_series(cascade::Cascade{T}, fun::Function, args...;
    x0 = WIDTH-100,
    y0 = 3*SEP,
    dx = 2*SEP,
    dy = SEP,
    space = SEP,
    idx = 1,
    kwargs...,
) where T <: Geometry

    y0 = y0 + FONTSIZE*(idx-1)

    shape = first(cascade.start.shape)
    setproperty!(shape, :position, (Luxor.Point(x0-dx, y0+dy), Luxor.Point(x0+dx,y0-dy)))

    label =_define_from(Label, string(fun), Luxor.Point(x0+dx+space, y0); halign=:left)
    return [shape, label]
end






function _define_from(::Type{Legend}, args...; kwargs...)
    return Legend([_define_from(Handle, args...; kwargs...)])
end


Base.push!(legend::Legend, h::Handle) = push!(legend.handle, h)

# Base.push!(legend::Legend, )


xshape = WIDTH-100;
yshape = 3*SEP

blend = Box(
    (Luxor.Point(xshape-SEP, yshape-0.5*SEP), Luxor.Point(xshape+SEP, yshape+0.5*SEP)),
    Blending(
        (Luxor.Point(xshape, yshape-0.5*SEP), Luxor.Point(xshape, yshape+0.5*SEP)),
        _define_gradient(HEX_GAIN, HEX_LOSS),
    ),
    :fill,
)




# # lab

# # Legend()

# series = [cas, annot]
# label = [shape, lab]




# vlims = vlim(cascade; locals..., kwargs...)
# pos = scale_for(calculate(copy(cascade), args...), Horizontal; kwargs...)

# lab = _define_annotation(cascade, Horizontal, args...)

# v = get_value(collect_data(cascade))