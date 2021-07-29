mutable struct Axis
    label::String
    ticklabels::AbstractArray
    ticksublabels::AbstractArray
    ticks::AbstractArray
    lim::Tuple
end


function Axis( ; label, ticklabels, ticksublabels=[], ticks, lim)
# function Axis( ; label="", ticklabels=[], ticksublabels=[], ticks=[], lim=tuple())
    isempty(ticksublabels) && (ticksublabels = fill("", size(ticklabels)))
    return Axis(label, ticklabels, ticksublabels, ticks, lim)
end

# function Axis( ; label, ticklabels, ticksublabels=[], ticks, lim)
#     # isempty(ticksublabels) && (ticksublabels = fill("", size(ticklabels)))
#     Axis(label, ticklabels, ticksublabels, ticks, lim)
# end


# function set_xaxis(data::Vector{Data}; label="")
#     N = length(data)
#     xticklabels = get_label.(data)
#     xticksublabels = get_sublabel.(data)
#     xticks = cumulative_x(; steps=N)
#     return Axis( ; label=label, ticklabels=xticklabels, ticksublabels=xticksublabels, ticks=xticks, lim=(1,N))
# end


# function set_yaxis(data::Vector{Data}; label="", kwargs...)
#     vlims = vlim(data)
#     vmin, vmax, vscale = vlims
#     yticklabels = collect(vmin:floor(vmax))
#     yticks = scale_y(yticklabels; vlims...)
#     return Axis( ; label=label, ticklabels=yticklabels, ticks=yticks, lim=(vmin,vmax))
# end