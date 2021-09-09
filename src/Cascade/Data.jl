mutable struct Data <: Sampling
    label::String
    sublabel::String
    order::Vector{Integer}
    value::Vector{Real}
end


"""
    Data( ; kwargs...)
This method allows for field order-independent Cascade-definition.

# Keyword Arguments
- `order=[]`: If unspecified, default to `1:length(value)`
"""
function Data( ; label, value, sublabel, order)
    return Data(label, sublabel, order, value)
end


## Get Data properties.

get_label(x::Data) = x.label

get_sublabel(x::Data) = x.sublabel

get_order(x::Data) = x.order
get_order(args...) = _get(get_order, args...)


"""
"""
get_value(x::Data) = x.value
get_value(args...) = _get(get_value, args...)


"""
"""
_get(fun::Function, data::Vector) = matrix(fun.(data))


## Set Data properties

"""
"""
function set_value!(x::Data, value)
    x.value = value
    # !!!! Do we want to reset order?
    x.order = 1:length(value)
    return x
end

set_value!(args...) = _set(set_value!, args...)


"""
"""
function set_order!(x::Data, order)
    tmp = Dict(k => v for (k,v) in zip(x.order, x.value))
    x.order = order
    set_value!(x, [tmp[k] for k in order])
    return x
end

set_order!(x::Vector{Data}, order) = [set_order!(x[ii], order) for ii in 1:length(x)]


"""
"""
_set(fun::Function, data::Vector{Data}, mat::AbstractMatrix) = fun.(data, vectorize(mat))