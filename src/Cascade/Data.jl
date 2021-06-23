mutable struct Data <: Sampling
    label::String
    sublabel::String
    order::Vector{Integer}
    value::Vector{Real}
end

"""
    Data( ; kwargs...)
This method allows for field order-independent Cascade-definition.

# Keyword arguments
- `order=[]`: If unspecified, default to `1:length(value)`
"""
function Data( ; label, value, sublabel="", order=[], kwargs...)
    isempty(order) && (order = collect(1:length(value)))
    
    return Data(label, sublabel, order, value)
end


function Data(sdf::DataFrames.SubDataFrame; label, sublabel="", value=VALUE_COL, kwargs...)
    sublabel!=="" && (sublabel = sdf[1,sublabel])
    return Data( ; label=sdf[1,label], sublabel=sublabel, value=sdf[:,value], kwargs...)
end


"Get properties"
get_label(x::Data) = x.label
get_sublabel(x::Data) = x.sublabel

get_order(x::Data) = x.order
get_order(args...) = _get(get_order, args...)

get_value(x::Data) = x.value
get_value(args...) = _get(get_value, args...)

_get(fun::Function, data::Vector) = convert(Matrix, fun.(data))
# _get(fun::Function, data::Vector) = LinearAlgebra.Matrix(hcat(fun.(data)...,)')


"Set properties"
set_label!(x::Data, label) = begin x.label = label; return x end
set_sublabel!(x::Data, sublabel) = begin x.sublabel = sublabel; return x end

set_value!(x::Data, value) = begin x.value = value; return x end
set_value!(args...) = _set(set_value!, args...)

function set_order!(x::Data, order)
    tmp = Dict(k => v for (k,v) in zip(x.order, x.value))
    x.order = order
    set_value!(x, [tmp[k] for k in order])
    return x
end

set_order!(x::Vector{Data}, order) = [set_order!(x[ii], order) for ii in 1:length(x)]


""
function _set(fun::Function, data::Vector{Data}, mat::Matrix{T}) where T<:Real
    vec = collect(collect.(eachrow(mat)))
    return fun.(data, vec)
end