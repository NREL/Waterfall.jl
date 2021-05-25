mutable struct Vertical <: Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Point,Point}}
end


function Vertical(data::Vector{Data}, args...; kwargs...)
    # x1, x2 = scale_x(data; subdivide=true)
    # y1, y2 = scale_y(data, args...)
    
    # return Vertical.(
    #     sign.(data),
    #     vectorize(Point.(x1,y1), Point.(x2,y2)),
    # )
    return _rectangle(Vertical, data, 1.0, args...; subdivide=true)
end