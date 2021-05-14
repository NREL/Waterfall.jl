mutable struct Cascade{T <: Sampling}
    start::T
    stop::T
    steps::Vector{T}
end


Cascade( ; start, stop, steps) = Cascade(start, stop, steps)


function Cascade(df::DataFrame; label, kwargs...)
    gdf = fuzzify(df; kwargs...)

    start = Data(first(gdf), label; kwargs...)
    stop = Data(last(gdf), label; kwargs...)
    steps = [Data(gdf[ii], label; kwargs...) for ii in 2:gdf.ngroups-1]

    data = [start;steps;stop]
    set_beginning!(data, cumulative_y(data,-1))
    set_ending!(data, cumulative_y(data))

    return Cascade(start, stop, steps)
end


function Cascade{Data}(value::Matrix{T}, label::Vector{String}) where T<:Real
    vbeg = cumulative_y(value,-1)
    vend = cumulative_y(value)

    N = size(value,1)
    start = Data(label=label[1], value=value[1,:], beginning=vbeg[1,:], ending=vend[1,:])
    stop = Data(label=label[N], value=value[N,:], beginning=vbeg[N,:], ending=vend[N,:])
    steps = [Data(label=label[ii], value=value[ii,:], beginning=vbeg[ii,:], ending=vend[ii,:])
        for ii in 2:N-1]

    return Cascade{Data}(start, stop, steps)
end


function Cascade{T}(fun::Function, cascade::Cascade{Data}) where T<:Sampling
    result = T(fun, collect_data(cascade))
    return Cascade(first(result), last(result), result[2:end-1])
end


function Cascade{T}(cascade::Cascade{Data}, args...) where T<:Sampling
    result = T(collect_data(cascade), args...)
    return Cascade(first(result), last(result), result[2:end-1])
end


Base.copy(x::Cascade) = Cascade(copy(x.start), copy(x.start), copy.(x.steps))

get_start(x::Cascade) = x.start
get_steps(x::Cascade) = x.steps
get_stop(x::Cascade) = x.stop
collect_data(x::Cascade) = Vector{Data}([x.start; x.steps; x.stop])

set_start!(x::Cascade, start) = begin x.start = start; return x end
set_steps!(x::Cascade, steps) = begin x.steps = steps; return x end
set_stop!(x::Cascade, stop) = begin x.stop = stop; return x end

function set_order!(x::Cascade, order)
    data = collect_data(x)
    [set_order!(d, order) for d in data]
    return x
end