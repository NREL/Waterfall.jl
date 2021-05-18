mutable struct Horizontal <: Points
    sign::Vector{Integer}
    points::Vector{Tuple{Point,Point}}
end


Horizontal(data::Vector{Data}, args...) = Horizontal(data, 1.0, args...)
# function Horizontal(data::Vector{Data}, args...)
#     y1 = scale_y(get_beginning, data, args...)
#     y2 = scale_y(get_ending, data, args...)

#     x1 = cumulative_x(data, -1.; subdivide=false)
#     x2 = cumulative_x(data,  0.; subdivide=false)

#     return Horizontal.(
#         sign.(data),
#         vectorize(Point.(x1,y1), Point.(x2,y2)),
#     )
# end


function Horizontal(data::Vector{Data}, p::Float64, args...)
    y1 = scale_y(get_beginning, data, args...)
    y2 = scale_y(get_ending, data, args...)

    x1 = cumulative_x(data, -(1-(1-p)/2); subdivide=false)
    x2 = cumulative_x(data,    -(1-p)/2; subdivide=false)

    return Horizontal.(
        sign.(data),
        vectorize(Point.(x1,y1), Point.(x2,y2)),
    )
end