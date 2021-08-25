mutable struct Parallel <: Geometry
    label::String
    shape::Vector{Line}
    nsample::Int
    annotation::Union{Label,Missing}
end