mutable struct Parallel <: Points
    sign::Vector{Integer}
    points::Vector{Tuple{Point,Point}}
end


function Parallel(data::Vector{Data}; kwargs...)
    idx1 = 1:(length(data)-1)
    idx2 = 2:length(data)

    x = cumulative_x(data, -0.5; kwargs...)

    y1 = scale_y(get_beginning, data[idx1])
    y2 = [
        scale_y(get_beginning, data[idx2])[1:end-1,:];
        scale_y(get_ending, data[[end]]);
    ]
    
    return Parallel.(
        vectorize(Integer.(sign.(-(y2.-y1)))),
        vectorize(Point.(x[idx1,:], y1), Point.(x[idx2,:], y2)),
    )
end