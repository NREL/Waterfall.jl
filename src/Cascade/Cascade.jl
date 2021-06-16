"""
"""
mutable struct Cascade2{T <: Sampling}
    start::T
    stop::T
    steps::Vector{T}
    order::Vector{Int64}
end


"""
    Cascade2( ; kwargs...)
This method allows for field order-independent Cascade2-definition.

# Keyword arguments
- `order=missing`: Unless otherwise defined, defaults to ordering steps in the order given.


    Cascade2(df::DataFrames.DataFrame; kwargs...)

# Arguments
- `df::DataFrames.DataFrame` of input data

# Keyword arguments
- `label::Symbol`: `df` column to use to label information
- See `Waterfall.fuzzify` and `Waterfall.Data`

# Returns
- `Cascade2{Data}`
"""
function Cascade2( ; start, stop, steps, order=missing, kwargs...)
    ismissing(order) && (order = collect(1:length(steps)))
    x = Cascade2(start, stop, steps, order)
end


function Cascade2(df::DataFrames.DataFrame; label, kwargs...)
    gdf = fuzzify(df; kwargs...)

    start = Data(first(gdf), label; kwargs...)
    stop = Data(last(gdf), label; kwargs...)
    steps = [Data(gdf[ii], label; kwargs...) for ii in 2:gdf.ngroups-1]

    data = [start;steps;stop]
    set_beginning!(data, cumulative_y(data,-1))
    set_ending!(data, cumulative_y(data))

    # Sort "start" samples by magnitude. Ensure consistent ordering in all subsequent steps.
    iiorder = sortperm(get_value(data[1]))
    [set_order!(data[ii], iiorder) for ii in 1:length(data)]

    return Cascade2( ; start=start, stop=stop, steps=steps, kwargs...)
end


get_start(x::Cascade2) = x.start
get_steps(x::Cascade2) = x.steps
get_stop(x::Cascade2) = x.stop
collect_data(x) = Vector{Data}([x.start; x.steps; x.stop])

set_start!(x::Cascade2, start) = begin x.start = start; return x end
set_steps!(x::Cascade2, steps) = begin x.steps = steps; return x end
set_stop!(x::Cascade2, stop) = begin x.stop = stop; return x end

function set_order!(x::Cascade2, order)
    # Update order and steps.
    x.order = order
    x.steps = x.steps[order]

    # Recalculate beginning and end based on new order.
    data = collect_data(x)
    set_beginning!(data, cumulative_y(data,-1))
    set_ending!(data, cumulative_y(data))

    return x
end


Base.copy(x::Cascade2) = Cascade2(copy(x.start), copy(x.stop), copy.(x.steps), copy.(x.order))

function Base.convert(::Type{Cascade2{T}}, cascade::Cascade2{Data}) where T <: Geometry
    result = T(collect_data(cascade))
    return Cascade2(first(result), last(result), result[2:end-1], cascade.order)
end