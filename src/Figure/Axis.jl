mutable struct Axis
    label::String
    ticklabels::AbstractArray
    ticks::AbstractArray
    lim::Tuple
end

Axis( ; label, ticklabels, ticks, lim) = Axis(label, ticklabels, ticks, lim)

function set_xaxis(data::Vector{Data}; label="")
    N = length(data)
    xticklabels = get_label.(data)
    xticks = cumulative_x(; steps=N)
    return Axis(label, xticklabels, xticks, (1,N))
end


function set_yaxis(data::Vector{Data}; label="")
    vmin, vmax, vscale = vlim(data)
    vlims = NamedTuple{(:vmin,:vmax,:vscale)}((vmin,vmax,vscale))
    yticklabels = collect(vmin:floor(vmax))
    yticks = scale_y(yticklabels; vlims...)
    return Axis(label, yticklabels, yticks, (vmin,vmax))
end