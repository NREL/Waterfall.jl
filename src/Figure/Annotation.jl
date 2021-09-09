mutable struct Annotation
    cascade::Cascade
    label::Vector{Label}
end

Annotation( ; cascade, label) = Annotation(cascade, label)