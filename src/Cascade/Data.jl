mutable struct Data <: Sampling
    label::String
    order::Vector{Integer}
    value::Vector{Real}
    beginning::Vector{Real}
    ending::Vector{Real}
end


function Data( ; label, order=[], value=[], beginning=[], ending=[], kwargs...)
    N = length(value)
    isempty(order) && (order = collect(1:N))
    isempty(value) && (value = fill(0.,N))
    isempty(beginning) && (beginning = fill(0.,N))
    isempty(ending) && (ending = fill(0.,N))

    return Data(label, order, value, beginning, ending)
end


function Data(sdf::DataFrames.SubDataFrame, label; value=:Value, kwargs...)
    return Data( ; label=sdf[1,label], value=sdf[:,value], kwargs...)
end


Base.copy(x::Data) = Data(x.label, copy.(x.order), copy.(x.value), copy.(x.beginning), copy.(x.ending))


"Get values"
get_label(x::Data) = x.label
get_order(x::Data) = x.order
get_value(x::Data) = x.value
get_beginning(x::Data) = x.beginning
get_ending(x::Data) = x.ending

""
_get(fun::Function, data::Vector) = LinearAlgebra.Matrix(hcat(fun.(data)...,)')
# _get(fun::Function, data::Vector{Data}) = LinearAlgebra.Matrix(hcat(fun.(data)...,)')
get_order(args...) = _get(get_order, args...)
get_value(args...) = _get(get_value, args...)
get_beginning(args...) = _get(get_beginning, args...)
get_ending(args...) = _get(get_ending, args...)


set_label!(x::Data, label) = begin x.label = label; return x end
set_value!(x::Data, value) = begin x.value = value; return x end
set_beginning!(x::Data, beginning) = begin x.beginning = beginning; return x end
set_ending!(x::Data, ending) = begin x.ending = ending; return x end


""
function _set(fun::Function, data::Vector{Data}, mat::Matrix{T}) where T<:Real
    vec = collect(collect.(eachrow(mat)))
    return fun.(data, vec)
end

set_order!(args...) = _set(set_order!, args...)
set_value!(args...) = _set(set_value!, args...)
set_beginning!(args...) = _set(set_beginning!, args...)
set_ending!(args...) = _set(set_ending!, args...)


function set_order!(x::Data, order)
    x.order = order
    x.value = x.value[order]
    x.beginning = x.beginning[order]
    x.ending = x.ending[order]
    return x
end