mutable struct Violin <: Points
    sign::Vector{Integer}
    points::Vector{Point}
end


function Violin(fun::Function, data::Vector{Data})
    x, y = scale_kde(fun, data)
    return Violin.(
        sign.(data),
        vectorize(Point.(x,y)),
    )
end


function scale_kde(fun::Function, data::Vector{Data})
    value = calculate_kde.(fun, data)
    
    vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
    y = get_x(value)
    y = scale_y(y; vlims...)

    xl, xr = scale_density(value; steps=length(data),)
    return hcat(xl,xr), hcat(y,y)
end