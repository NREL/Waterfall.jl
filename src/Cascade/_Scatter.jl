mutable struct Scatter <: Geometry
    sign::Vector{Integer}
    points::Vector{Luxor.Point}
end


function Scatter(fun::Function, data::Vector{Data})
    x = cumulative_x(data, -0.5)
    y = scale_y(fun, data)

    return Scatter.(
        sign.(data),
        vectorize(Luxor.Point.(x,y)),
    )
end

get_points(x::Scatter) = x.points