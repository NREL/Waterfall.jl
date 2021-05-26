mutable struct Vertical <: Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Luxor.Point,Luxor.Point}}
end


function Vertical(data::Vector{Data}, args...; kwargs...)
    return _rectangle(Vertical, data, 1.0, args...; subdivide=true)
end