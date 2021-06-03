# # https://cran.r-project.org/web/packages/GauPro/vignettes/IntroductionToGPs.html#:~:text=Gaussian%20correlation,correlation%20function%20is%20the%20Gausian.&text=The%20parameters%20%CE%B8%3D(%CE%B81,Gaussian%20process%20model%20to%20data.
# # https://scipy-cookbook.readthedocs.io/items/CorrelatedRandomSamples.html

# import LinearAlgebra
# import Distributions
# import Plots

# DATA_DIR = joinpath(WATERFALL_DIR,"data","pvrd")
# df = CSV.read(joinpath(DATA_DIR,"pvrd2-investment-metrics.csv"), DataFrames.DataFrame)
# df[!,:Label] .= string.(titlecase.(df[:,:Process])," (",df[:,:Step],")")
# df[!,:Units] .= "Efficiency (%)"
# # value=:Value
# # fuzziness=(0.01,0.1)
# # samples=10

# # Random.seed!(1234)
# # steps = size(df,1)
# # df[!,:fuzziness] .= _fuzzify_uniform(fuzziness, steps)

# # # Correlation.
# # X = randn(steps,steps)
# # A = X' * X
# # C = LinearAlgebra.cholesky(A)

# # # Randomness.
# # distribution = fill(:normal,steps)
# # mu = df[:,value]
# # fuzziness = df[:,:fuzziness]
# # N=samples
# # seed=-1


# # # result = hcat([_fuzzify(d,x,f,N; seed=s)
# # #     for (d,x,f,s) in zip(distribution, mu, fuzziness, seed)]...,)

# # function _correlated_fuzzify(fuzziness, N; seed=1234)
# #     Random.seed!(seed)
# #     return rand(Distributions.Normal(0, abs(fuzziness)), N)
# # end

# # function _correlated_fuzzify(mu, fuzziness, N; seed=-1)
# #     steps = length(mu)
# #     seed = seed<0 ? make_seed.(fuzziness) : fill(seed,length(mu))
# #     randomness = hcat([_correlated_fuzzify(f, N; seed=s) for (f,s) in zip(fuzziness,seed)]...)'

# #     X = randn(steps,steps)
# #     A = X' * X
# #     C = LinearAlgebra.cholesky(A / maximum(A))

# #     result = C.L * randomness
# #     return result .+ mu
# # end

# function random_rotation(dim::Integer, numrand::Integer)
#     X = I(dim)
# end

Random.seed!(1234)
# random_index(numindex=3)
numindex=2
numrand=3


# begin xrand = []; yrand=[] end
# [push!(xrand, rand(setdiff(1:dim,xrand))) for ii in 1:numrand]
# [push!(yrand, rand(setdiff(1:dim,[yrand;xrand[ii]]))) for ii in 1:numrand]

# function random_index(dim, numrand)
#     idx = fill(1:dim,2)
#     idx = vec(collect(collect.(Iterators.product(idx...))))
    
#     return Random.shuffle(idx)[1:numrand]
# end


list_indices(dim::Integer) = vec(collect(collect.(Iterators.product(fill(1:dim,2)...))))

function random_index(
    mat::Union{LinearAlgebra.LowerTriangular,LinearAlgebra.UnitLowerTriangular},
    numrand::Integer;
    seed=1
)
    idx = list_indices(size(mat,1))
    idx = idx[getindex.(idx,2) .< getindex.(idx,1)]

    Random.seed!(seed)
    return Random.shuffle(idx)[1:numrand]
end

function random_rotation(dim::Integer, numrand::Integer; seed=1234)
    rot = zeros(dim,dim)+I(dim)
    idx = random_index(LinearAlgebra.LowerTriangular(rot), numrand)

    Random.seed!(seed)
    val = rand(numrand)

    for ii in 1:numrand
        rot[idx[ii]...] = val[ii]
        rot[reverse(idx[ii])...] = val[ii]
    end

    return rot
end

# function random_rotation(dim::Integer; seed=1234)
#     Random.seed!(seed)
#     return randn(dim,dim)
# end

# xfilled = fill([], (dim,dim))
# [xfilled[ii...] = ii for ii in idx]

# ii = .!DataFrames.nonunique(DataFrames.DataFrame(x=sort.(xout)))



# for ii in 1:numrand
    
# end
# x = 