mutable struct Vertical <: Points
    sign::Vector{Integer}
    points::Vector{Tuple{Point,Point}}
end


function Vertical(data::Vector{Data})
    x1 = cumulative_x(data, -1.)
    x2 = cumulative_x(data,  0.)

    y1 = scale_y(get_beginning, data)
    y2 = scale_y(get_ending, data)
    
    return Vertical.(
        sign.(data),
        vectorize(Point.(x1,y1), Point.(x2,y2)),
    )
end