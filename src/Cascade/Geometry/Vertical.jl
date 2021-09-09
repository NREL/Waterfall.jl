mutable struct Vertical <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
end


function Vertical( ; label, shape, nsample)
    return Vertical(label, shape, nsample)
end