# https://discourse.julialang.org/t/generate-random-value-from-a-given-function-out-of-box/5793/3
using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))


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

    median = cat([get_value(collect_data(calculate(cascades[k], Statistics.quantile, 0.5))) for k in lst]...; dims=2)

    # vals = LinearAlgebra.Matrix(cat([heights[k] for k in lst]...; dims=2))
    # fun!==identity && (vals = fun(vals; dims=2))

    # set_value!.(data, vectorize(vals))
    set_value!.(data, vectorize(median))
    return cascade
end

# nperm = 10
nsample = 5

# # xperm = define_permute(df, nperm; fun=Statistics.mean, kwargs...)
# xperm = cumulative_spread(df; nperm=nperm, nsample=nsample, ncor=ncor, kwargs...)
# xperm = set_geometry(xperm, Parallel, false; hue="black")

# # cascade = define_from(Cascade{Data}, df; interactivity(0.01,0.3), nsample=nsample, ncor=ncor, permutation=lst[2], kwargs...)
# # pdata = define_from(Plot{Data}, copy(cascade); ylabel="Efficiency (%)")
# # phoriz = set_geometry(pdata, Horizontal; colorcycle=true)

perms = vcat([[
    ii,
    swapat!(copy(ii), 1, 2),
    # swapat!(copy(ii), 1, length(ii)),
    # reverse(ii),
] for ii in [collect(1:4)]]...)

for geometry in [Vertical]
# for geometry in [Parallel]
    # for nsample in [1,10,50]
    for nsample in [1]
        # for colorcycle in [true,false]
        for colorcycle in [true]
            for perm in [perms[end]]

                (length(perm)>length(COLORCYCLE) && colorcycle) && continue

                
                locals = (
                    nsample = nsample,
                    permutation = perm,
                    permute = true,
                    ncor = true,
                    correlate = true,
                    colorcycle = colorcycle,
                    ylabel = "Efficiency (%)",
                )
                
                global cascade = define_from(Cascade{Data}, df; locals..., kwargs...)
                global plot = define_from(Plot{geometry}, copy(cascade); locals..., kwargs...)
                
                # cmean = set_geometry(calculate(copy(cascade), Statistics.mean), Horizontal;
                # style=:stroke, alpha=1.0, locals...,
                # )
                # dmean = collect_data(cmean)
                # [setfield!(x, :annotation, missing) for x in dmean]
                
                # vlims = vlim(collect_data(cascade); locals..., kwargs...)
                # vmin, vmax, vscale = vlims

                Luxor.@png begin
                    Luxor.fontface("Gill Sans")
                    Luxor.fontsize(FONTSIZE)
                    Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])
                    
                    draw(plot)
                    # _draw(plot.title)

                    # nsample>1 && draw(cmean)
                    
                end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER+padding(plot.axes[1]) plot.path
            end
        end
    end
end