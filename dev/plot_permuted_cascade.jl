using Waterfall
import Luxor
import Base
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
permute = true
perms = [[collect(1:N)]; Waterfall.random_permutation(1:N, min(factorial(N),nperm))]

perm = perms[2]
# args = (quantile=1.0,)

for perm in perms
    x = Cascade(df; permutation=perm, minrot=0.01, maxrot=0.3, nsample=nsample, ncor=ncor, kwargs...)
    
    T = Parallel
    p = Plot(copy(x); ylabel="Efficiency")

    pv = convert(Plot{Vertical}, p; permute=true)

    Luxor.@png begin
        Luxor.fontsize(18)
        Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

        draw(pv; distribution=distribution, samples=nsample)
    end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER filename(pv)
end

# # _convert(::Type{T}, x, args...; kwargs...) where T<:Geometry = _convert!(T, copy(x), args...; kwargs...)




# # function select_row(v::Vector, ii)
# # end





# # function Base.convert(::Type{Matrix}, lst) where T<:Real
# #     return _convert(::Type{Matrix}, lst, 2)
# # end






# # function permute!(x::Cascade)
# # end

# # xv = convert(Cascade{Vertical}, x)
# # 