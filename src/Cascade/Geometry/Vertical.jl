mutable struct Vertical <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
    annotation::Union{Labelbox,Missing}
end


function Vertical( ; label, shape, nsample, annotation)
    return Vertical(label, shape, nsample, annotation)
end