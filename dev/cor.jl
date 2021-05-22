v = get_value(data)

x = v[[2:end-2],:]
y = v[[3:end-1;end-1],:]

x = [c[:] for c in eachcol(x)]
y = [c[:] for c in eachcol(y)]