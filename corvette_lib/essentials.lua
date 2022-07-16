require("corvette_lib/ui")
---@param s string
---@param sep string
---@return string[]
string.split = function(s, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
        table.insert(t, str) end
    return t
end
essentials = {
    ---@param only_charged boolean|nil
    ---@return "dt"|"hs"|false
    get_exploit = function(only_charged)
        if ui.antiaim.main.general.fake_duck:get() then
            return false end
        if only_charged and exploits.get_charge() < 0 then
            return false end
        if ui.aimbot.general.exploits.doubletap:get() then
            return "dt" end
        if ui.aimbot.general.exploits.hideshots:get() then
            return "hs" end
        return false
    end,
    ---@return boolean
    is_desync_inverted = function()
       return antiaim.get_desync_side() == 2
    end,
    get_anim_time = function(speed)
        return global_vars.frame_time() * (speed or 14)
    end,
    anim = function(a, b, t)
        t = essentials.get_anim_time(t)
        return a + (b - a) * t
    end,
}
clamp = function(val, min, max)
    return math.max(min, math.min(max, val))
end