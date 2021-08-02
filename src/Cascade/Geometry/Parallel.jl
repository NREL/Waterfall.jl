mutable struct Parallel <: Geometry
    label::String
    attribute::Vector{Line}
    nsample::Int
end