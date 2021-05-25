import Base


# Base.show(io::IO, data::Data) = print(io, data.label)

Base.show(io::IO, data::Data) = print(io, _show(data)...)
Base.show(io::IO, cascade::Cascade{Data}) = print(io, _show(cascade; maxlen=3)...)

function _show(cascade::Cascade{T}; kwargs...) where T<:Sampling
    fields = fieldnames(Cascade)
    return vcat(
        Printf.@sprintf("%s\n",typeof(cascade)),
        indent.(vcat([_show(cascade, field; kwargs...) for field in fields]...),1),
    )[1:end-1]
end

function _show(plot::Cascade{T}; kwargs...) where T<:Sampling
    fields = fieldnames(Cascade)
    return vcat(
        Printf.@sprintf("%s\n",typeof(cascade)),
        indent.(vcat([_show(cascade, field; kwargs...) for field in fields]...),1),
    )[1:end-1]
end


function _show(data::Data; show_type=true, kwargs...)
    # fields = collect(fieldnames(Data))
    fields = setdiff(collect(fieldnames(Data)),[:label])
    str = vcat(
        Printf.@sprintf("%s\"%s\"\n", (show_type ? "Data: " : ""), data.label),
        [Printf.@sprintf("%s%-11s %s\n", indent(), "$field:", _show(getproperty(data,field)))
            for field in fields]
    )
    return str
end

function _show(axis::Axis; kwargs...)
    fields = setdiff(collect(fieldnames(Axis)),[:label])
    str = vcat(
        Printf.@sprintf("\"%s\"\n", axis.label),
        [Printf.@sprintf("%s%-11s %s\n", indent(), "$field:", _show(getproperty(axis,field)))
            for field in fields]
    )
    return str
end




function _show(cascade::Cascade, field::Symbol; kwargs...)
    return vcat(_show(field, getproperty(cascade,field); kwargs...), "\n")
end


# Should be able to merge these two.....
function _show(field::Symbol, property::Vector; kwargs...)
    return vcat(
        Printf.@sprintf("%s: %d-element %s\n", field, length(property), typeof(property)),
        indent.(_show(property; kwargs...), 1),
    )
end

function _show(field::Symbol, property; kwargs...)
    return vcat(
        Printf.@sprintf("%s: %s\n", field, typeof(property)),
        indent.(_show(property; kwargs...), 1),
    )
end


function _show(lst::Vector{Data}; maxlen=missing)
    N = length(lst)
    if N==1
        str = _show(lst[1])
    else
        !ismissing(maxlen) && (maxlen=max(3,maxlen))
        shorten = !ismissing(maxlen) && N>maxlen
        N1 = shorten ? maxlen-2 : N-1

        idx = [1:N1;N]
        str = itemize.(_show.(lst[idx]), idx)

        str = vcat(str[1:N1]..., " ⋮\n"^shorten, str[end])
        str = str[.!isempty.(str)]
    end
    return str
end

function _show(mat::Matrix; kwargs...)
    return if size(mat,2)==1
        _show(mat[:,1]; kwargs...)
    end
end

function _show(lst::Vector; maxlen=5)
    all(typeof.(pdata.xaxis.ticklabels).==String) && (maxlen=4)
    if length(lst)==1
        str = _show(lst[1])
    else
        shorten = length(lst)>maxlen

        N1 = shorten ? maxlen-2 : length(lst)-1

        str1 = string(string.(_show.(lst[1:N1]),", ")...)
        str2 = _show(lst[end])

        str = Printf.@sprintf("%s%s%s", str1, (shorten ? "… " : ""), str2)
    end
    return str
end


_show(x::String) = Printf.@sprintf("\"%s\"", x)
_show(x::Float64) = Printf.@sprintf("%.5g", x)
_show(x::Integer) = Printf.@sprintf("%d", x)
_show(x::Tuple) = _show(collect(x))

_show(x::Symbol, T::DataType) = Printf.@sprintf("%s: %s", x, T)


function indent(str::String, args...; kwargs...)
    if str!=="\n"
        m = match.(r"^(\n)?(.*\n?)", str)
        str = string((isnothing(m[1]) ? "" : m[1]), indent(args...; kwargs...), m[2])
    end
    return str
end

indent(level::Integer=1; spaces::Integer=2) = " "^(spaces*level)


function itemize!(lst::Vector{String}, ii::Integer)
    lst[1] = Printf.@sprintf("%2d) %s", ii, lst[1])
    lst[2:end] .= indent.(lst[2:end], 2)
    return lst
end

itemize(lst, ii) = itemize!(copy(lst),ii)

# print(_show(data; maxlen=4)...)