using Waterfall
include(joinpath(WATERFALL_DIR,"src","includes.jl"))

function _ticks(cascade::Cascade{Data}; vmin=missing, vmax=missing, kwargs...)
    if |(ismissing(vmin), ismissing(vmax))
        major = _major_order(cascade)
        minor = _minor_order(cascade)
        
        vsum = Statistics.cumsum(collect_value(cascade); dims=1)[1:end-1,:]
        vsum = round.(vsum; digits=-minor)
        
        if ismissing(vmin)
            vmin = minimum(vsum)
            vmin!==0.0 && (vmin = floor(vmin-0.5*exp10(major); digits=-major))
        end

        if ismissing(vmax)
            vmax = maximum(vsum)
            vmax!==0.0 && (vmax = ceil(maximum(vsum) + 0.5*exp10(major); digits=-major))
        else
            vmax = floor(vmax; digits=major)
        end
    else
        vmax = floor(vmax; digits=major)
        major = _major_order([vmin,vmax])
    end

    ticks = vmin:exp10(major):vmax
    length(ticks)<4 && (ticks = vmin:0.5*exp10(major):vmax)
    return ticks
end


function _vlim(cascade; vmin=missing, vmax=missing, kwargs...)
    if |(ismissing(vmin), ismissing(vmax))
        tcks = _ticks(cascade; kwargs...)
        
        vmin = first(tcks)
        vmax = convert(Float64, last(tcks) + 0.5*tcks.step)
    end
    
    vscale = HEIGHT / (vmax-vmin)
    return (vmin=vmin, vmax=vmax, vscale=vscale)
end


T = Horizontal
nsample = 10
value = :Value
sample = :Sample
label = :Category
sublabel = :Amount
colorcycle = true
kwargs = (value=value, sample=sample, label=label, colorcycle=colorcycle)

TOP_BORDER=48+SEP

# Read amounts and save investment order.

options = Dict(
    :Index=>"Reduction in MJSP",
    # :Index=>"Reduction in Jet GHG",
    :Technology=>"HEFA Camelina",
)

# Define the directory, and make sure only to save directory 
directory = "/Users/chughes/Documents/Git/tyche-graphics/tyche/src/waterfall/data/6f84f6cf-0b43-31a2-9706-576272778f20"
subdirs = joinpath.(directory, readdir(directory))
subdirs = subdirs[.&(isnothing.(match.(r"(.*[.].*)", subdirs)), isnothing.(match.(r".*/fig", subdirs)))]
subdir = subdirs[3]

# When creating an animation, we first need to read the complete cascade to calculate
# the y-axis limits in order to maintain consistent scaling throughout.
cascade = read_from(Cascade{Data}, subdir; options = options, kwargs...)

tcks = _ticks(cascade)
vlims = _vlim(cascade)