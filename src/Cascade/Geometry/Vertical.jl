mutable struct Vertical <: Geometry
    label::String
    attribute::Vector{Box}
    nsample::Int
    annotation::Union{Label,Missing}
end