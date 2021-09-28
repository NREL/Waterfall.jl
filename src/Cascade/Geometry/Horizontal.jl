mutable struct Horizontal <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
end


function Horizontal( ; label, shape, nsample)
    return Horizontal(label, shape, nsample)
end