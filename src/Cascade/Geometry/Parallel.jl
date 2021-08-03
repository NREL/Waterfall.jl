mutable struct Parallel <: Geometry
    label::String
    attribute::Vector{Line}
    nsample::Int
    annotation::Union{Label,Missing}
end