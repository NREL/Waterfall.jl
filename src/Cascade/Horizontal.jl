mutable struct Horizontal <: Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Luxor.Point,Luxor.Point}}
end


function Horizontal(data::Vector{Data}, p::Float64, args...; kwargs...)
    return _rectangle(Horizontal, data, p, args...; subdivide=false)
end

Horizontal(data::Vector{Data}, args...; kwargs...) = Horizontal(data, 1.0, args...; kwargs...)