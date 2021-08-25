mutable struct Vertical <: Geometry
    label::String
    shape::Vector{Box}
    nsample::Int
    annotation::Union{Labelbox,Missing}
end