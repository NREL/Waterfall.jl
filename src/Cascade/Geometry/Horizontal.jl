mutable struct Horizontal <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
    annotation::Union{Labelbox,Missing}
end


function Horizontal( ; label, shape, nsample, annotation)
    return Horizontal(label, shape, nsample, annotation)
end