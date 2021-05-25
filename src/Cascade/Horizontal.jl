mutable struct Horizontal <: Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Point,Point}}
end


function Horizontal(data::Vector{Data}, p::Float64, args...; kwargs...)
    # x1, x2 = scale_x(data, p; subdivide=false)
    # y1, y2 = scale_y(data, args...)

    # return Horizontal.(
    #     sign.(data),
    #     vectorize(Point.(x1,y1), Point.(x2,y2)),
    # )
    return _rectangle(Horizontal, data, p, args...; subdivide=false)
end

Horizontal(data::Vector{Data}, args...; kwargs...) = Horizontal(data, 1.0, args...; kwargs...)