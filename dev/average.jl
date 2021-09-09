using Waterfall

include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))

# RETURNS HEIGHT.
function _cumulative_spread(cascade::Cascade{Data}; kwargs...)
    data = collect_data(cascade)
    vstart, vstop = cumulative_v!(cascade; kwargs...)  # DOES it update cascade????

    vrange = hcat(vstart,vstop)
    vmax = Statistics.maximum(vrange; dims=2)
    vmin = Statistics.minimum(vrange; dims=2)

    sgn = [vmax[ii] in vstart[ii,:] ? -1 : 1 for ii in 1:length(vmax)]

    return sgn .* (vmax.-vmin)
end


function _cumulative_spread(df; nperm, kwargs...)
    ROW = size(df,1)-2

    perms = random_permutation(1:ROW, min(factorial(ROW), nperm))
    !(1:ROW in perms) && append!(deleteat!(perms,nperm), [collect(1:ROW)])

    result = zeros(ROW+2,nperm)

    for ii in 1:nperm
        cascade = define_from(Cascade{Data}, df; permutation=perms[ii], kwargs...)
        #     ncor=ncor,
        #     nsample=nsample,
        #     kwargs...,
        # )

        height = _cumulative_spread(cascade)
        result[collect_permutation(perms[ii]),[ii]] .= height
    end

    return result
end


# function cumulative_spread!(cascade::Cascade{Data})
#     data = collect_data(cascade)
#     vstart, vstop = cumulative_v!(cascade; kwargs...)  # DOES it update cascade????

#     vrange = hcat(vstart,vstop)
#     vmax = Statistics.maximum(vrange; dims=2)
#     vmin = Statistics.minimum(vrange; dims=2)

#     sgn = [vmax[ii] in vstart[ii,:] ? -1 : 1 for ii in 1:length(vmax)]
#     height = sgn .* (vmax.-vmin)

#     # set_value!(data, height)
#     # return cascade
# end




# cascades = Dict()


function cumulative_spread(df; nperm=100, kwargs...)
    cascade = define_from(Cascade{Data}, df; kwargs...)

    v = _cumulative_spread(df; nperm=nperm, kwargs...)
    data = collect_data(cascade)
    set_value!(data,v)

    return cascade
end


nsample=10
ncor=1000
nperm=3
cspread = cumulative_spread(df; nperm=nperm, nsample=nsample, ncor=ncor, kwargs...)


# IF max comes from start, it's going down. Otherwise it's going up.

# sgn = sign.(vstop.-vstart)