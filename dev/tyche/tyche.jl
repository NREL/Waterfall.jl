#= !!!!
    Make sure we have all of the optimization info.
    Maybe in a struct?
=# 

using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

T = Horizontal
nsample = 10
value = :Value
sample = :Sample
label = :Category
colorcycle = true
ylabel = "MJSP"

kwargs = (value=value, sample=sample, label=label, colorcycle=colorcycle, ylabel=ylabel)


"""
    _read_from(::Type{DataFrames.DataFrame}, path; kwargs...)
    _read_from(::Type{Vector{Data}}, path; kwargs...)
This method reads the data file in `path` into the given `DataType`

# Arguments
- `path::String` to '.csv' file storing values.
"""
function _read_from(::Type{DataFrames.DataFrame}, path::String; index, kwargs...)
    idx = DataFrames.DataFrame(index)
    df = CSV.read(path, DataFrames.DataFrame)
    return DataFrames.innerjoin(idx, df, on=intersect(propertynames(idx),propertynames(df)))
end

function _read_from(::Type{Vector{Data}}, path::String; kwargs...)
    df = _read_from(DataFrames.DataFrame, path; kwargs...)
    return define_from(Vector{Data}, df; kwargs...)
end


"""
    _aggregate(data; kwargs...)

# Keyword Arguments
- `label`
- `sublabel`
- `order`
"""
function _aggregate(data; label, sublabel="", order=missing, kwargs...)
    value = Statistics.sum(get_value(data); dims=1)[1,:]
    order = coalesce(order, collect(1:length(value)))
    return Data( ; label=label, sublabel=sublabel, order=order, value=value)
end


"""
    define_from(Cascade{Data}, directory; kwargs...)
"""
function define_from(::Type{Cascade{Data}}, directory::String; kwargs...)
    files = readdir(directory)
    value_files = joinpath.(directory, files[.!isnothing.(match.(r"(value.*.csv)", files))])
    amt = CSV.read(joinpath(directory,"amounts.csv"), DataFrames.DataFrame)
    opt = CSV.read(joinpath(directory,"options.csv"), DataFrames.DataFrame)[:,2:end]
    
    # Read data and save start/stop values.
    data = _read_from.(Vector{Data}, value_files; index=:Index=>"MJSP", kwargs...)
    start = _aggregate(first(data); label="start", sublabel="")
    stop = _aggregate(last(data); label="stop", sublabel="")
    N = length(data)-1

    # Assume steps are net current values at each step, and not differences.
    # Calculate differences and save as steps.
    tmp = copy.(data[1])
    order = amt[:,:Order]

    v1 = collect_value(data[1:end-1], order)
    v2 = collect_value(data[2:end], order)
    value = vectorize(v2.-v1)

    steps = Data.(
        get_label.(tmp)[order],
        get_sublabel.(tmp)[order],
        fill(collect(1:length(first(tmp))), N),
        value
    )

    return update_stop!(Cascade( ;
        start = start,
        stop = stop,
        steps = steps,
        permutation = order,
        correlation = I(N+2),
        ispermuted = true,
        iscorrelated = true,
    ))
end


function define_from(::Type{Plot{T}}, directory::String; kwargs...) where T<:Geometry
    cascade = define_from(Cascade{Data}, directory; kwargs...)
    plot = define_from(Plot{T}, copy(cascade); nsample=length(cascade), kwargs...)
    plot.path = joinpath(directory, lowercase(string(T))*".png")
    return plot
end



# index = :Index => "Reduction in MJSP"
DATA_DIR = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/278d4ec6-6987-3726-bba9-bb89f9d39b48"

cascade = define_from(Cascade{Data}, DATA_DIR; kwargs...)
plot = define_from(Plot{T}, DATA_DIR; kwargs...)

Luxor.@png begin
    Luxor.fontface("Gill Sans")
    Luxor.fontsize(FONTSIZE)
    Luxor.setline(1.0)
    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

    draw(plot)
    # draw(plot.legend)
    # println(_padding(plot))
    
end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+_padding(plot) plot.path