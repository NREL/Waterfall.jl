"""
    mutable struct Blending
        direction::Tuple{Luxor.Point,Luxor.Point}
        hue::Tuple{Luxor.RGB,Luxor.RGB}
    end

Color gradient from the starting to stopping position of each waterfall in the cascade.
The gradient begins with the "natural" color (the color that would be used if a gradient
was not applied) and ends in the lightened color.

Blending is applied to `Plot{Vertical}`, for which sample information does not overalp.
If a waterfall contains both positive and negative values, gradients will be defined and
applied separately, so that **all** positive values have the same starting/stopping gradient
position and/or color and **all** negative values have the same starting/stopping gradient
position and/or color.

Arguments:
- `direction::Tuple{Luxor.Point,Luxor.Point}`, the gradient's starting and stopping points.
- `hue::Tuple{Luxor.RGB,Luxor.RGB}`, the gradient's starting and stopping colors.
"""
mutable struct Blending
    direction::Tuple{Luxor.Point,Luxor.Point}
    hue::Tuple{Luxor.RGB,Luxor.RGB}
end