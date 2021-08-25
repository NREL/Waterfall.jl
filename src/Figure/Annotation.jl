mutable struct Annotation
    label::Labelbox
    shape<:Shape
    cascade::Union{Cascade{Horizontal},Missing}
end




# function Annotation(label, plot::Plot{Data})
#     plot = calculate_stat(plot, label)
#     plot = convert(Plot{Horizontal}, plot)
#     # !!!! would be nice if we could draw this from Horizontal. Would need to make sure
#     # scaling works out for vlim
#     return Annotation(label, annotate_for(plot, "mean").cascade)
# end


# function calculate_stat(plot::Plot{Data}, stat::String, args...; kwargs...)
#     return if stat=="mean";  calculate_mean(plot)
#     elseif stat=="quantile"; calculate_quantile(plot, args...; kwargs...)
#     end
# end

# calculate_stat(plot, args::Tuple; kwargs...) = calculate_stat(plot, args...; kwargs...)




# "This function highlights a metric in the plot."
# function annotate_for(p::Plot{Data}, stat::String, args...; kwargs...)
#     return if stat=="mean";  calculate_mean(p)
#     elseif stat=="quantile"; calculate_quantile(p, args...; kwargs...)
#     end
# end

# annotate_for(p::Plot{Data}, args::Tuple; kwargs...) = annotate_for(p, args...; kwargs...)



# # Annotation(label, cascade)