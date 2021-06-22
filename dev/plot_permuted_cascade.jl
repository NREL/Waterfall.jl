using Waterfall
import Luxor
include(joinpath(WATERFALL_DIR,"bin","io.jl"))
# include(joinpath(WATERFALL_DIR,"src","utils","correlate.jl"))
include(joinpath(WATERFALL_DIR,"src","utils","draw.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Axis.jl"))
# include(joinpath(WATERFALL_DIR,"src","Figure","Plot.jl"))
# include(joinpath(WATERFALL_DIR,"src","Cascade","Vertical.jl"))
# include(joinpath(WATERFALL_DIR,"src","Cascade","Parallel.jl"))

filename(p::Plot) = filename(p.cascade)

function filename(x::Cascade{T}) where T <: Geometry
    path = joinpath(WATERFALL_DIR,"fig","perm",lowercase(string(T)))
    !isdir(path) && mkpath(path)
    order = [Printf.@sprintf("-%02d", perm) for perm in x.permutation]
    return joinpath(path, lowercase(string(T, order..., ".png")))
end

nstep = 3
nsample = 1
nperm = 10
ncor = 1000
N = 13
perms = [[collect(1:N)]; Waterfall.random_permutation(1:N, min(factorial(N),nperm))]

# perm = perms[2]
for perm in perms
    x = Cascade(df; permutation=perm, minrot=0.01, maxrot=0.3, nsample=nsample, ncor=ncor, kwargs...)
    p = Plot(x; ylabel="Efficiency")

    pv = convert(Plot{Vertical}, p)
#     pp = convert(Plot{Parallel}, p)

    Luxor.@png begin
        Luxor.fontsize(18)
        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

        draw(pv; distribution=distribution, samples=nsample)
    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER filename(pv)
end

# v = Waterfall.rowprod(x)
# N = length(v)
# order = 1:N


# function permute!(x::Cascade)
# end

# xv = convert(Cascade{Vertical}, x)
# 