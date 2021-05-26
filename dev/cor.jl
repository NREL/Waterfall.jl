v = get_value(data)

x = v[2:end-2,:]
y = v[3:end-1,:]

# xlst = [c[:] for c in eachcol(x)]
# ylst = [c[:] for c in eachcol(y)]

covariance = LinearAlgebra.LowerTriangular(Statistics.cov(v, v; dims=2))
