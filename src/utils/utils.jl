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


"""
This function returns a filename
"""
function filename(p::Plot{T}, stat; opacity="", distribution=:normal, frame=missing,
) where T <: Points

    dir = joinpath(FIG_DIR,lowercase(string(T)))
    fig = Printf.@sprintf("%s_n%02.0f_%s_%s", T, length(p), distribution, _write_stat(stat))

    if !ismissing(frame)
        dir = joinpath(dir, fig)
        fig = Printf.@sprintf("frame%02.0f", frame)
    end

    !isdir(dir) && mkpath(dir)
    return joinpath(dir, lowercase(fig * ".png"))
end


function filename(p::Plot{T}, stat::AbstractArray; kwargs...) where T <: Points
    return filename(p, string(string.(_write_stat.(stat),"_")...)[1:end-1]; kwargs...)
end


function filename(p::SplitPlot{T1,T2}, stat; opacity="", distribution=:normal, frame=missing,
) where {T1<:Points, T2<:Points}

    dir = joinpath(FIG_DIR,lowercase(string(T)))
    fig = Printf.@sprintf("%s_n%02.0f_%s_%s", T1, length(p), distribution, _write_stat(stat))

    if !ismissing(frame)
        dir = joinpath(dir, fig)
        fig = Printf.@sprintf("frame%02.0f", frame)
    end

    !isdir(dir) && mkpath(dir)
    return joinpath(dir, lowercase(fig * ".png"))
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


""
_write_stat(x::String) = x
_write_stat(x::Tuple) = x[1] * Printf.@sprintf("%03.0f", x[2]*100)

_label_stat(x::String) = x
_label_stat(x::Tuple) = ordinal(x[2])

function ordinal(x::Float64)
    suffix = " %ile"
    str = Printf.@sprintf("%.0f", x*100)
    return if str[end]=='1'; str * "st" * suffix
    elseif str[end]=='2';    str * "nd" * suffix
    else;                    str * "th" * suffix
    end
end


"This function highlights a metric in the plot."
function highlight(p::Plot{Data}, stat::String, args...; kwargs...)
    return if stat=="mean"
        calculate_mean(p)
    elseif stat=="quantile"
        calculate_quantile(p, args...; kwargs...)
    end
end

highlight(p::Plot{Data}, args::Tuple; kwargs...) = highlight(p, args...; kwargs...)








function draw_highlight(p::Plot{Data}, stat; kwargs...)
    phighlight = highlight(p, stat)
    draw(phighlight; style=:stroke, opacity=1.0)

end