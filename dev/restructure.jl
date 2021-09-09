# https://discourse.julialang.org/t/generate-random-value-from-a-given-function-out-of-box/5793/3
using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
# include(joinpath(WATERFALL_DIR,"dev","legend.jl"))


# function define_permute(df, nperm::T; kwargs...) where T<:Integer
#     N = size(df,1)-2
#     lst = [[collect(1:N)]; random_permutation(1:N, min(factorial(N),nperm))]
#     return define_permute(df, lst; kwargs...)
# end

function define_permute(df::DataFrames.DataFrame, lst::T; fun::Function=identity, kwargs...) where T<:AbstractArray
    cascades = Dict()
    heights = Dict()

    for k in lst
        cascade = define_from(Cascade{Data}, df;
            permutation=k,
            nsample=100,
            correlate=true,
            permute=false,
            ncor=true,
            kwargs...,
        )
        push!(cascades, k => cascade)

        v1 = cumulative_v(cascade; shift=-1.0, kwargs...)
        v2 = cumulative_v(cascade; shift= 0.0, kwargs...)
        push!(heights, k => v2.-v1)
    end

    # Make dictionary of heights into one cascade.
    cascade = copy(cascades[first(lst)])
    data = collect_data(cascade)

    median = cat([collect_value(calculate(cascades[k], Statistics.quantile, 0.5)) for k in lst]...; dims=2)

    set_value!.(data, vectorize(median))
    return cascade
end

nsample = 5

perms = vcat([[
    ii,
    swapat!(copy(ii), 1, 2),
] for ii in [collect(1:4)]]...)

for T in [Horizontal]
# for T in [Parallel]
    # for nsample in [1,10,50]
    for nsample in [5]
        # for colorcycle in [true,false]
        for colorcycle in [false]
            for perm in [perms[end]]

                (length(perm)>length(COLORCYCLE) && colorcycle) && continue
                
                global locals = (
                    nsample = nsample,
                    permutation = perm,
                    permute = true,
                    ncor = true,
                    correlate = true,
                    colorcycle = colorcycle,
                    ylabel = "Efficiency (%)",
                    usegradient = false,
                )
                
                global cascade = define_from(Cascade{Data}, df; locals..., kwargs...)
                global plot = define_from(Plot{T}, copy(cascade); locals..., kwargs...)

                # --- STILL GOOD ---
                # global legd = _push!(
                #     _define_legend(plot.cascade; locals..., kwargs...),
                #     cascade, T, Statistics.mean; locals..., kwargs...
                # )

                Luxor.@png begin
                    Luxor.fontface("Gill Sans")
                    Luxor.fontsize(FONTSIZE)
                    Luxor.setline(1.0)
                    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

                    draw(plot)
                    # draw(legd)
                    # draw(h)
                    # draw(a)
                    # draw(ha)
                    # [draw(h[ii].shape) for ii in 1:length(h)]
                    # [draw(h[ii].label) for ii in 1:length(h)]

                    # draw(lab)
                    # draw(cas)

                    # global s = _define_series(cas, Statistics.mean)
                    # draw(s)

                    # xshape = WIDTH-100;
                    # yshape = 3*SEP
                    # wid = 2*SEP
                    
                    # blend = [
                    #     Box(
                    #         (Luxor.Point(xshape-wid, yshape-SEP/2), Luxor.Point(xshape+wid, yshape+SEP/2)),
                    #         _define_from(Coloring, HEX_GAIN),
                    #         :fill,
                    #     ),
                    #     Box(
                    #         (Luxor.Point(xshape-wid, yshape+FONTSIZE-SEP/2), Luxor.Point(xshape+wid, yshape+FONTSIZE+SEP/2)),
                    #         _define_from(Coloring, HEX_LOSS),
                    #         :fill,
                    #     )
                    # ]

                    # leg = [
                    #     _define_from(Label, "GAIN", Luxor.Point(xshape+wid+SEP, yshape); halign=:left, scale=0.8),
                    #     _define_from(Label, "LOSS", Luxor.Point(xshape+wid+SEP, yshape+FONTSIZE); halign=:left, scale=0.8),
                    # ]

                    # draw(blend)
                    # draw(leg)

                    # nsample>1 && draw(cmean)
                    
                end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+padding(plot.axes[1]) plot.path
            end
        end
    end
end