ss = render.get_screen_size()
hitgroups = {
    [0] = "generic",
    [1] = "head",
    [2] = "chest",
    [3] = "stomach",
    [4] = "left arm",
    [5] = "right arm",
    [6] = "left leg",
    [7] = "right leg",
    [8] = "neck",
    [10] = "gear"
}
set = function(elems)
    local t = {}
    for _, v in pairs(elems) do
        t[v] = true end
    return t
end
clamp = function(val, min, max) return math.max(min, math.min(max, val)) end

IEngine = ffp.create_interface("engine", "VEngineClient014")