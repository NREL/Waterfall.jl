mutable struct Box
    label::String
    value::Real
    xmid::Real
    ymid::Real
    width::Real
    height::Real
end

Box(; label, value, xmid, ymid, width, height) = Box(label, value, xmid, ymid, width, height)

function Box(label; value=0, xmid=0, ymid=0, width=0, height=0)
    return Box(label, value, xmid, ymid, width, height)
end

get_xmid(x::Box) = x.xmid
get_ymid(x::Box) = x.ymid
get_width(x::Box) = x.width
get_height(x::Box) = x.height
get_label(x::Box) = x.label
get_value(x::Box) = x.value

set_xmid!(x::Box, xmid) = x.xmid=xmid
set_ymid!(x::Box, ymid) = x.ymid=ymid
set_width!(x::Box, width) = x.width=width
set_height!(x::Box, height) = x.height=height