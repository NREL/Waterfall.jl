mutable struct Violin <: Geometry
    label::String
    shape::Poly
    nsample::Int
    annotation::Union{Label,Missing}
end