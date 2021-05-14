vectorize(x::Matrix) = collect.(collect(eachrow(x)))
vectorize(mat...) = vectorize(Tuple.(hcat.(mat...)))

get_x(x::KernelDensity.UnivariateKDE) = x.x
get_x(args...) = _get(get_x, args...)

get_density(x::KernelDensity.UnivariateKDE) = x.density
get_density(args...) = _get(get_density, args...)


Base.sign(data::T) where T <: Data = Integer.(sign.(get_value(data)))


Base.length(x::T) where T <: Points = length(x.points)
Base.length(x::T) where T <: Cascade = length(x.start)

Base.length(x::SplitPlot{T1,T2}) where {T1<:Points, T2<:Points} = length(x.beginning)
Base.length(x::Plot{T}) where T<:Points = length(x.cascade)


function scale_saturation(rgb::Luxor.RGB, args...)
    hsv = scale_saturation(Luxor.convert(Luxor.Colors.HSV, rgb), args...)
    return Luxor.convert(Luxor.Colors.RGB, hsv)
end

function scale_saturation(hsv::Luxor.HSV, f=0.0)
    if f!==0.0
        saturation = f<0 ? hsv.s * (1+f) : (1-hsv.s)*f + hsv.s
        hsv = Luxor.Colors.HSV(hsv.h, saturation, hsv.v)
    end
    return hsv
end


function filename(p::Plot{T}; opacity="", distribution=:normal, frame=missing, mean
) where T <: Points

    dir = joinpath(FIG_DIR,lowercase(string(T)))
    fig = Printf.@sprintf("%s_n%02.0f_%s_mean%g", T, length(p), distribution, mean)

    if !ismissing(frame)
        dir = joinpath(dir, fig)
        fig = Printf.@sprintf("frame%02.0f", frame)
    end

    !isdir(dir) && mkpath(dir)
    return joinpath(dir, lowercase(fig * ".png"))
end

function filename(p::SplitPlot{T1,T2};
    opacity="",
    distribution=:normal,
    kwargs...,
) where {T1<:Points, T2<:Points}
    dir = joinpath(FIG_DIR,lowercase(string(T1,"_",T2)))
    fig = Printf.@sprintf("%s_%s_n%02.0f_%s_mean%g", T1, T2, length(p), distribution, mean)

    !isdir(dir) && mkpath(dir)
    return joinpath(dir, lowercase(fig * ".png"))
end