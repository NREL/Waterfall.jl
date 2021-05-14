function vlim(data::Vector{Data})
    v = dropzero(get_beginning(data))

    vmin = floor(minimum(v)*0.9)
    vmax = round(maximum(v))+0.5
    vscale = HEIGHT/(vmax-vmin)
    return vmin, vmax, vscale
end


# Scale
scale_y(v::VecOrMat{T}; vmin, vscale, vmax) where T<:Real = -vscale * (max.(v,vmin) .- vmax)

function scale_y(fun::Function, data::Vector{Data})
    vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
    return scale_y(fun(data); vlims...)
end

function scale_y(fun::Function, data::Vector{Data}, vlims)
    # vlims = NamedTuple{(:vmin,:vmax,:vscale)}(vlim(data))
    return scale_y(fun(data); vlims...)
end

scale_y(fun::Function, cascade::Cascade) = scale_y(fun, collect_data(cascade))
scale_y(fun::Function, cascade::Cascade, vlims) = scale_y(fun, collect_data(cascade), vlims)