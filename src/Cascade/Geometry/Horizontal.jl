mutable struct Horizontal <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
    annotation::Union{Labelbox,Missing}
end