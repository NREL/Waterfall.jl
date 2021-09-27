"""
    fuzzify(df::DataFrames.DataFrame; kwargs...)
This function adds "fuzziness" to an input `df`

# Keyword Arguments
- value::Symbol=VALUE_COL
- nsample::Integer=50
- distribution::Symbol=:normal
- factor
"""
function fuzzify(df;
    value = VALUE_COL,
    sample = SAMPLE_COL,
    units = :Units,
    label = missing,
    sublabel = missing,
    kwargs...,
)
    # If samples are not already included in the DataFrame, add them.
    if !(:Sample in propertynames(df))
        val = random_samples(df[:,value]; kwargs...)
        update_stop!(val)
        
        df = DataFrames.crossjoin(df, DataFrames.DataFrame(sample=>1:size(val,2)))
        df[!,value] .= vcat(val'...)
    end

    idx = DataFrames.Not([value, sample])
    return DataFrames.groupby(df, idx)
end


"""
    read_from(::Type{DataFrames.DataFrame}, file; kwargs...)
    read_from(::Type{Vector{Data}}, file; kwargs...)
    define_from(Cascade{Data}, directory; kwargs...)
    define_from(Plot{T}, directory; kwargs...) where T<:Geometry
These methods read data from a `directory` into the specified `DataType`.
Defining a plot preserves `plot.path=directory`, and names the output data file for the
plot geometry, so that if, for example, a horizontal plot is defined and plotted, it will be
saved to `directory/horizontal.png`.

# Arguments
- `file::String` to '.csv' file storing values.
"""
function read_from(::Type{DataFrames.DataFrame}, file::String; options::Dict=Dict(), kwargs...)
    df = CSV.read(file, DataFrames.DataFrame)
    if !isempty(options)
        options = DataFrames.DataFrame(options)
        df = DataFrames.innerjoin(df, options,
            on = intersect(propertynames(options), propertynames(df)),
        )
    end
    return df
end


function read_from(::Type{DataFrames.GroupedDataFrame}, file::String, cols; kwargs...)
    df = read_from(DataFrames.DataFrame, file; kwargs...)
    cols = get_names(df, cols)
    return DataFrames.groupby(df, cols)
end


function read_from(::Type{DataFrames.SubDataFrame},
    file::String,
    idx::Int,
    cols = DataFrames.Not([Float64,Int]) ;
    kwargs...,
)
    gdf = read_from(DataFrames.GroupedDataFrame, file, cols; kwargs...)
    return gdf[idx]
end


function read_from(::Type{Cascade{Data}}, directory; kwargs...)
    # Read other information.
    amt = CSV.read(joinpath(directory,"amounts.csv"), DataFrames.DataFrame)
    permutation = CSV.read(joinpath(directory,"order.csv"), DataFrames.DataFrame)[:,1]
    
    files = readdir(directory)
    files = joinpath.(directory, files[.!isnothing.(match.(r"(value.*.csv)", files))])
    
    start = _read_pool(first(files); label_value="state of technology", kwargs...)
    stop = _read_pool(last(files); label_value="stop", kwargs...)
    steps = _read_step(files, permutation; kwargs...)
    N = length(steps)

    return update_stop!(Cascade( ; 
        start = start,
        stop = stop,
        steps = steps,
        permutation = permutation,
        correlation = I(N+2),
        ispermuted = !(permutation==1:N),
        iscorrelated = true,
    ))
end


function read_from(::Type{Plot{T}}, directory::String;
    rng=missing,
    ylabel=:Index,
    units=:Units,
    options::Dict,
    kwargs...,
) where T<:Geometry
    cascade = read_from(Cascade{Data}, directory; options=options, kwargs...)
    nsample = length(cascade)

    !ismissing(rng) && getindex!(cascade, rng)

    # Read ylabel info.
    df = _read_values(directory, 1; kwargs...)
    ylabel_str, units_str = values(df[df[:,ylabel].==options[ylabel], [ylabel,units]][1,:])
    metric_str = df[1,:Metric]
    
    cascade.stop.label = "Projected " * ylabel_str
    
    plot = define_from(Plot{T}, copy(cascade);
        ylabel = "$ylabel_str ($units_str)",
        nsample=nsample,
        path=directory,
        kwargs...,
    )

    plot.title = _define_title(options[:Technology]; metric=metric_str, nsample=nsample, rng=rng)
    plot.path = _define_path(plot, directory; ylabel=ylabel_str, nsample=nsample, rng=rng, kwargs...)
    
    return plot
end


"""
    _read_step(file, idx; kwargs...)
"""
function _read_step(file::String, idx::Int; kwargs...)
    sdf = read_from(DataFrames.SubDataFrame, file, idx; kwargs...)
    return define_from(Data, sdf; kwargs...)
end

function _read_step(paths::Vector{String}, idx::Vector{Int};
    calculate_difference=true,
    kwargs...,
)
    v2 = _read_step.(paths[2:end], idx; kwargs...)

    if calculate_difference
        v1 = _read_step.(paths[1:end-1], idx; kwargs...)
        set_value!(v2, get_value(v2) .- get_value(v1))
    end

    return v2
end


"""
    _read_pool(file::String; kwargs...)
"""
function _read_pool(file::String;
    label,
    sublabel=missing,
    label_value=missing,
    sublabel_value=missing,
    kwargs...,
)
    # df = read_from(DataFrames.DataFrame, file; options=options)
    cols = DataFrames.Not(ismissing(sublabel) ? [Float64,label] : [Float64,label,sublabel])
    gdf = read_from(DataFrames.GroupedDataFrame, file, cols; kwargs...)
    val = get_names(first(gdf), Float64)

    df = DataFrames.combine(gdf, val .=> sum .=> val)

    !ismissing(label_value) && (df[!,label] .= label_value)
    !ismissing(sublabel_value) && (df[!,sublabel] .= sublabel_value)
    return define_from(Data, df; label=label, sublabel=sublabel, kwargs...)
end


"""
"""
function _read_values(directory; kwargs...)
    files = readdir(directory)
    files = joinpath.(directory, files[.!isnothing.(match.(r"(value.*.csv)", files))])
    return CSV.read.(files, DataFrames.DataFrame)
end

_read_values(directory, idx; kwargs...) = _read_values(directory; kwargs...)[idx]


"""
"""
get_names(df, type::DataType) = DataFrames.propertynames(df)[get_type(df).==type]
get_names(df, col::Symbol) = intersect(DataFrames.propertynames(df), [col;])
get_names(df, lst) = union([get_names(df, x) for x in lst]...)
get_names(df, x::DataFrames.InvertedIndex) = DataFrames.Not(get_names(df, x.skip))


get_type(df) = DataFrames.eltype.(DataFrames.skipmissing.(DataFrames.eachcol(df)))


"""
"""
_distribution_error(args...) =  _option_error("distribution", [:normal,:uniform], args...)


""
function _option_error(option, allowed::String)
    throw(ArgumentError("Allowed values for $option: $allowed"))
end

function _option_error(option, allowed::AbstractArray)
    return _option_error(option, string((string.(allowed).*", ")...,)[1:end-2])
end

function _option_error(option, allowed, value)
    return if isempty(value)
        _option_error(option, allowed)
    else
        throw(ArgumentError("$option = $value. Allowed values: $allowed"))
    end
end