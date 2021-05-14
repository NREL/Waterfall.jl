mutable struct Coloring
    hue::Luxor.RGB
    saturation::Float64
    opacity::Float64
end

function Coloring(hue::String; saturation=0.0, opacity=1.0, kwargs...)
    rgb = parse(Luxor.Colorant, hue)
    return Coloring(scale_saturation(rgb, saturation), saturation, opacity)
end

# Needs saturation for blend. Or this should be another type. AHHH THIS IS HARD.
function Coloring(x::T; hue=missing, kwargs...) where T <: Points
    hue = ismissing(hue) ? get_hue.(x.sign; kwargs...) : fill(hue, length(x))
    return Coloring.(hue; kwargs...)
end


# "This function returns the hue associated with whether the value is a gain or loss."
get_hue(sign::Integer; kwargs...) = sign<0 ? HEX_LOSS : HEX_GAIN