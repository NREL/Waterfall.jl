mutable struct Parallel <: Geometry
    label::String
    shape::Vector{Line}
    nsample::Int
end


function Parallel( ; label, shape, nsample)
    return Parallel(label, shape, nsample)
end