"""
    fuzzify(df::DataFrames.DataFrame; kwargs...)
This function adds "fuzziness" to an input `df`

# Keyword Arguments
- value::Symbol=:Value
- samples::Integer=50
- distribution::Symbol=:normal
- factor
"""
function fuzzify(df;
    value=:Value,
    numsample=SAMPLES,
    kwargs...,
)
    idx = DataFrames.Not([value,SAMPLE])

    if numsample==1
        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE => 1:numsample))
        df[end,value] *= -1
    else
        val = df[:,value]
        val = random_samples(val, numsample; kwargs...)
        val[end,:] .= -Statistics.cumsum(val; dims=1)[end-1,:]

        df = DataFrames.crossjoin(df, DataFrames.DataFrame(SAMPLE=>1:numsample))
        df[!,value] .= vcat(val'...)
    end

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