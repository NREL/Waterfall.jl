mutable struct Violin <: Geometry
    label::String
    shape::Poly
    nsample::Int
    annotation::Union{Labelbox,Missing}
end