mutable struct Ticks
    shape::Array{Line}
    arrow::Tuple{Luxor.Point,Luxor.Point}
end

Ticks( ; shape, arrow) = Ticks(shape, arrow)