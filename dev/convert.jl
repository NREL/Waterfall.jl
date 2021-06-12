function Base.convert(::Type{Cascade{T}}, cascade::Cascade{Data}) where T <: Geometry
    result = T(collect_data(cascade))
    return Cascade(first(result), last(result), result[2:end-1])
end


function Base.convert(::Type{Plot{T}}, plot::Plot{Data}) where T <: Geometry
    fields = setdiff(fieldnames(Plot), [:cascade])
    cascade = convert(Cascade{T}, plot.cascade)
    other = [getproperty(plot,field) for field in fields]
    return Plot(cascade, other...)
end