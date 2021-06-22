mutable struct Violin <: Geometry
    sign::Vector{Integer}
    points::Vector{Luxor.Point}
end


# function Violin(data::Vector{Data}; kwargs...)
#     x, y = scale_kde(get_ending, data)

#     return Violin.(
#         sign.(data),
#         vectorize(Luxor.Point.(x,y)),
#     )
# end