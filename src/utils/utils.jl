vectorize(x::Matrix) = collect.(collect(eachrow(x)))
vectorize(mat...) = vectorize(Tuple.(hcat.(mat...)))

get_x(x::KernelDensity.UnivariateKDE) = x.x
get_x(args...) = _get(get_x, args...)

get_density(x::KernelDensity.UnivariateKDE) = x.density
get_density(args...) = _get(get_density, args...)


Base.sign(data::T) where T <: Data = Integer.(sign.(get_value(data)))


# Base.length(x::T) where T <: Geometry = length(x.sign)
# Base.length(x::T) where T <: Cascade = length(x.start)
# Base.length(x::T) where T <: Axis = length(x.ticks)
# Base.length(x::Plot{T}) where T<:Geometry = length(x.cascade)


"This function returns all permutations of the elements in the input vectors or vector of vectors"
permute(x::Vector{Vector{T}}) where T<: Any = permute(x...)
permute(x::Vararg{Any}) = vec(collect(collect.(Iterators.product(x...))))


"This function returns all of the ways to combine the elements in `lst`. At the moment,
due to memory size, this will truncate to a maximum length of `maxlen=6`."
function combinate(lst::AbstractArray; maxlen=6)
    lst = collect(lst)[1:max(length(lst),maxlen)]
    x = fill(collect(lst), length(lst))
    x = permute(x)
    return sort(x[vec(length.(unique.(x)).==length.(x))])
end


# """
# This function returns a filename
# """
# function filename(p::Plot{T}, stat; opacity="", distribution=:normal, frame=missing,
# ) where T <: Geometry
#     dir = joinpath(FIG_DIR,lowercase(string(T)))
#     fig = Printf.@sprintf("%s_n%02.0f_%s", T, length(p), distribution)

#     !isempty(stat) && (fig = Printf.@sprintf("%s_%s", fig, _write_stat(stat)))

#     if !ismissing(frame)
#         dir = joinpath(dir, fig)
#         fig = Printf.@sprintf("frame%02.0f", frame)
#     end

#     !isdir(dir) && mkpath(dir)
#     return joinpath(dir, lowercase(fig * ".png"))
# end


# function filename(p::Plot{T}, stat::AbstractArray; kwargs...) where T <: Geometry
#     stat = copy(stat)
#     iitup = typeof.(stat) .<: Tuple
#     stat[iitup] .= sort(stat[iitup])
#     return filename(p, string(string.(_write_stat.(stat),"_")...)[1:end-1]; kwargs...)
# end


# function filename(p::Plot{T}; opacity="", distribution=:normal, frame=missing, mean
# ) where T <: Geometry

#     dir = joinpath(FIG_DIR,lowercase(string(T)))
#     fig = Printf.@sprintf("%s_n%02.0f_%s_mean%g", T, length(p), distribution, mean)

#     if !ismissing(frame)
#         dir = joinpath(dir, fig)
#         fig = Printf.@sprintf("frame%02.0f", frame)
#     end

#     !isdir(dir) && mkpath(dir)
#     return joinpath(dir, lowercase(fig * ".png"))
# end


# ""
# _write_stat(x::String) = x
# _write_stat(x::Tuple) = x[1] * Printf.@sprintf("%03.0f", x[2]*100)

# _label_stat(x::String) = x
# _label_stat(x::Tuple) = ordinal(x[2])

# function ordinal(x::Float64)
#     suffix = " %ile"
#     str = Printf.@sprintf("%.0f", x*100)
#     return if str[end]=='1'; str * "st" * suffix
#     elseif str[end]=='2';    str * "nd" * suffix
#     else;                    str * "th" * suffix
#     end
# end











# function draw_highlight(p::Plot{Data}, stat; kwargs...)
#     phighlight = highlight(p, stat)
#     draw(phighlight; style=:stroke, opacity=1.0)

# end