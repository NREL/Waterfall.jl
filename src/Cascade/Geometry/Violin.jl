mutable struct Violin <: Geometry
    label::String
    shape::Poly
    nsample::Int
end


function Violin( ; label, shape, nsample)
    return Violin(label, shape, nsample)
end