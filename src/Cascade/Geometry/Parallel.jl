mutable struct Parallel <: Geometry
    label::String
    shape::Vector{Line}
    nsample::Int
    annotation::Label
end


function Parallel( ; label, shape, nsample, annotation)
    return Parallel(label, shape, nsample, annotation)
end