mutable struct Handle
    shape::Shape
    label::Label{String}
end

Handle( ; shape, label) = Handle(shape, label)