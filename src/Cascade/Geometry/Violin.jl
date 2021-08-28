mutable struct Violin <: Geometry
    label::String
    shape::Poly
    nsample::Int
    annotation::Label
end


function Violin( ; label, shape, nsample, annotation)
    return Violin(label, shape, nsample, annotation)
end