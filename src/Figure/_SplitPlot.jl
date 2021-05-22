mutable struct SplitPlot{T1 <: Sampling, T2 <: Sampling}
    beginning::Cascade{T1}
    ending::Cascade{T2}
    xaxis::Axis
    yaxis::Axis
end


function SplitPlot{T1,T2}(p::Plot) where {T1<:Sampling, T2<:Sampling}
    beginning = Cascade{T1}(get_beginning, p.cascade)
    ending = Cascade{T2}(get_ending, p.cascade)
    return SplitPlot{T1,T2}(beginning, ending, p.xaxis, p.yaxis)
end