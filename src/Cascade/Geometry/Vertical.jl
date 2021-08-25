mutable struct Vertical <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
    annotation::Union{Label,Missing}
end