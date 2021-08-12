mutable struct Face <: Asset
    color::Union{Blending,Coloring}
    style::Symbol
end


function _face( ; facecolor="black", facealpha=1.0, facestyle)
    return Face(Coloring( ; hue=facecolor, alpha=facealpha), facestyle)
end

# function Face( ; color, style=:fill, kwargs...)
#     return Face(color, style)
# end


# # need: default coloring.

# # face( ; color="black", )