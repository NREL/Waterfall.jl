mutable struct Horizontal <: Geometry
    label::String
    attribute::Vector{Box}
    nsample::Int
    annotation::Union{Label,Missing}
end


# function horizontal(label::)
# end


# select ii-th order in color cycle from x.permutation???


# hue = _hue.(v)
# opacity = _opacity(v)


