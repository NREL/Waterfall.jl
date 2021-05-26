mutable struct Parallel <: Geometry
    sign::Vector{Integer}
    points::Vector{Tuple{Luxor.Point,Luxor.Point}}
end


# function Parallel(data::Vector{Data}; kwargs...)
#     idx1 = 1:(length(data)-1)
#     idx2 = 2:length(data)

#     x = cumulative_x(data, -0.5; kwargs...)

#     y1 = scale_y(get_beginning, data[idx1])
#     y2 = [
#         scale_y(get_beginning, data[idx2])[1:end-1,:];
#         scale_y(get_ending, data[[end]]);
#     ]
    
#     return Parallel.(
#         vectorize(Integer.(sign.(-(y2.-y1)))),
#         vectorize(Luxor.Point.(x[idx1,:], y1), Luxor.Point.(x[idx2,:], y2)),
#     )
# end

function Parallel(data::Vector{Data}, args...; kwargs...)
    # # x1, x2 = scale_x(data; subdivide=false)
    # x1 = cumulative_x(data, -1.0; subdivide=false, space=false)
    # x2 = cumulative_x(data,  0.; subdivide=false, space=false)
    # y1, y2 = scale_y(data)

    # return Parallel.(
    #     sign.(data),
    #     vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2)),
    # )
    return _rectangle(Parallel, data, 1.0, args...; subdivide=false, space=false)
end



function _rectangle(T::DataType, data::Vector{Data}, quantile::Real, args...; kwargs...)
    x1, x2 = scale_x(data, quantile; kwargs...)
    y1, y2 = scale_y(data, args...)

    return T.(sign.(data), vectorize(Luxor.Point.(x1,y1), Luxor.Point.(x2,y2)))
end