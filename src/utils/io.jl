"""
    fuzzify(df::DataFrames.DataFrame; kwargs...)
This function adds "fuzziness" to an input `df`

# Keyword Arguments
- value::Symbol=
- samples::Integer=50
- distribution::Symbol=:normal
- factor
"""
function fuzzify(df;
    value=VALUE_COL,
    kwargs...,
)
    val = random_samples(df[:,value]; kwargs...)
    val[end,:] .= -Statistics.cumsum(val; dims=1)[end-1,:]

    df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE_COL=>1:size(val,2)))
    df[!,value] .= vcat(val'...)

    idx = DataFrames.Not([value,SAMPLE_COL])
    return DataFrames.groupby(df, idx)
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