mutable struct Violin <: Geometry
    label::String
    attribute::Poly
    nsample::Int
    annotation::Union{Label,Missing}
end