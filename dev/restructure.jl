using Waterfall

# include("")
include(joinpath(WATERFALL_DIR,"src","includes.jl"))
include(joinpath(WATERFALL_DIR,"bin","io.jl"))


function define_permute(df, nperm::T; kwargs...) where T<:Integer
    N = size(df,1)-2
    lst = [[collect(1:N)]; random_permutation(1:N, min(factorial(N),nperm))]
    return define_permute(df, lst; kwargs...)
end

function define_permute(df::DataFrames.DataFrame, lst::T; fun::Function=identity, kwargs...) where T<:AbstractArray
    cascades = Dict()
    heights = Dict()

    for k in lst
        cascade = define_from(Cascade{Data}, df; permutation=k, nsample=10, ncor=1000, kwargs...)
        push!(cascades, k => cascade)

        v1, v2 = cumulative_v!(cascade; kwargs...)
        push!(heights, k => v2.-v1)
    end

    # Make dictionary of heights into one cascade.
    cascade = copy(cascades[first(lst)])
    data = collect_data(cascade)

    vals = LinearAlgebra.Matrix(cat([heights[k] for k in lst]...; dims=2))
    fun!==identity && (vals = fun(vals; dims=2))

    set_value!.(data, vectorize(vals))
    return cascade
end


nperm = 10

# xperm = define_permute(df, nperm; fun=Statistics.mean, kwargs...)
xperm = cumulative_spread(df; nperm=nperm, nsample=nsample, ncor=ncor, kwargs...)
xperm = set_geometry(xperm, Parallel, false; hue="black")

# cascade = define_from(Cascade{Data}, df; minrot=0.01, maxrot=0.3, nsample=nsample, ncor=ncor, permutation=lst[2], kwargs...)
# pdata = define_from(Plot{Data}, copy(cascade); ylabel="Efficiency (%)")
# phoriz = set_geometry(pdata, Horizontal; colorcycle=true)

name_perm(x) = Printf.@sprintf("-%02.0f", x)
name_perm(x::AbstractArray) = string(name_perm.(x)..., ".png")

name(x::Cascade{T}) where T<:Geometry = "fig/" * lowercase(string(T)) * name_perm(x.permutation)
name(p::Plot{T}) where T<:Geometry = name(p.cascade)

# xhoriz = set_geometry(cascade, Horizontal; colorcycle=false)
# xvert = set_geometry(cascade, Vertical; colorcycle=false)

N=10
lst = [[collect(1:N)]; random_permutation(1:N, min(factorial(N),nperm))]

# plot = phoriz
ncor=1000

for ii in 1:N

    cascade = define_from(Cascade{Data}, df; minrot=0.01, maxrot=0.3, nsample=nsample, ncor=ncor, permutation=lst[ii], kwargs...)
    pdata = define_from(Plot{Data}, copy(cascade); ylabel="Efficiency (%)")
    plot = set_geometry(pdata, Horizontal; colorcycle=true)

    Luxor.@png begin
        Luxor.fontsize(14)
        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])
        
        draw(plot)
        
        # draw(plot.cascade)
        
        Luxor.setcolor(Luxor.sethue("black")..., 1.0)
        draw(xperm)
        # Luxor.line(xperm.start.attribute[1].position..., xperm.start.attribute[1].style)
        # _draw_title(plot)
        # draw(plot.axes)

        # return nothing
        

    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER name(plot)
end