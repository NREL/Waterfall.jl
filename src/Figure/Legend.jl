mutable struct Legend
    annotation::Vector{Annotation}
    handle::Vector{Handle}
end

Legend( ; annotation, handle) = Legend(annotation, handle)