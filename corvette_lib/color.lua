---@class color_t
local color_mt = getmetatable(color_t(0, 0, 0))
---@class color_t
local color_mt_ext = {}
---@param s color_t
---@param a number
---@return color_t
color_mt_ext.alpha = function (s, a)
    return color_t(s.r, s.g, s.b, a)
end
---@param s color_t
---@param a number
---@return color_t
color_mt_ext.alp = function (s, a)
    return color_t(s.r, s.g, s.b, a * 255)
end
local o_color_mt_index = color_mt.__index
color_mt.__index = function(s, k)
    local value = color_mt_ext[k]
    if value then return value end
    return o_color_mt_index(s, k)
end