mutable struct Violin <: Geometry
    points::Vector{Luxor.Point}
    attr::Attribute
end


function Violin(data::Vector{Data}; kwargs...)
    x, y = scale_kde(get_ending, data)

    return Violin.(
        sign.(data),
        vectorize(Luxor.Point.(x,y)),
    )
end



function Waterfall.Violin(cascade::Cascade; kwargs...)
    x, y = Waterfall.scale_kde(cascade)
    data = Waterfall.collect_data(cascade)

    return Violin.(
        fill(1, size(x)),
        Waterfall.vectorize(Luxor.Point.(x,y)),
    )
end