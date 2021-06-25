mutable struct Parallel <: Waterfall.Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Luxor.Point,Luxor.Point}}
end