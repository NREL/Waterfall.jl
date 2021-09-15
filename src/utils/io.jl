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
    read_from(::Type{DataFrames.DataFrame}, path; kwargs...)
    read_from(::Type{Vector{Data}}, path; kwargs...)
This method reads the data file in `path` into the given `DataType`

# Arguments
- `path::String` to '.csv' file storing values.
"""
function read_from(::Type{DataFrames.DataFrame}, path::String; index, kwargs...)
    idx = DataFrames.DataFrame(index)
    df = CSV.read(path, DataFrames.DataFrame)
    return DataFrames.innerjoin(idx, df, on=intersect(propertynames(idx),propertynames(df)))
end

function read_from(::Type{Vector{Data}}, path::String; kwargs...)
    df = read_from(DataFrames.DataFrame, path; kwargs...)
    return define_from(Vector{Data}, df; kwargs...)
end


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