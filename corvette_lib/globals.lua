ss = render.get_screen_size()
set = function(elems)
    local t = {}
    for _, v in pairs(elems) do
        t[v] = true end
    return t
end
clamp = function(val, min, max) return math.max(min, math.min(max, val)) end
