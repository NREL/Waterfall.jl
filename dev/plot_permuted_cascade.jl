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
    file = lowercase(string(T, order..., ".png"))
    path = joinpath(path, file)
    println("Saving $path")
    return path
end

nstep = 3
nsample = 1
nperm = 8
ncor = 1000
N = 13
permute = true
perms = [[collect(1:N)]; Waterfall.random_permutation(1:N, min(factorial(N),nperm))]

perm = perms[2]
# args = (quantile=1.0,)

# for T in [Parallel,Horizontal,Vertical]
for T in [Vertical]
    for perm in perms
        x = Cascade(df; permutation=perm, interactivity=(0.01,0.3), nsample=nsample, ncor=ncor, kwargs...)
        
        pdata = Plot(copy(x); ylabel="Efficiency (%)")
        p = convert(Plot{T}, pdata, 1.0; permute=true)

        Luxor.@png begin
            Luxor.fontsize(18)
            Luxor.setmatrix([1 0 0 1 LEFT_BORDER TOP_BORDER])

            draw(p; distribution=distribution, samples=nsample)
        end WIDTH+LEFT_BORDER+RIGHT_BORDER HEIGHT+TOP_BORDER+BOTTOM_BORDER filename(p)
    end
end

# # _convert(::Type{T}, x, args...; kwargs...) where T<:Geometry = _convert!(T, copy(x), args...; kwargs...)




# # function offdiag_rowonal(v::Vector, ii)
# # end





# # function Base.convert(::Type{Matrix}, lst) where T<:Real
# #     return _convert(::Type{Matrix}, lst, 2)
# # end






# # function permute!(x::Cascade)
# # end

# # xv = convert(Cascade{Vertical}, x)
# # 