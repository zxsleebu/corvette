---@class vec2_t
---@operator mul(number|vec2_t): vec2_t
---@operator div(number|vec2_t): vec2_t
---@operator add(number|vec2_t): vec2_t
---@operator sub(number|vec2_t): vec2_t
local vec2_mt = getmetatable(vec2_t())
local operation2 = function(a, b, f)
    if type(b) == "number" then
        return vec2_t(f(a.x, b), f(a.y, b)) end
    return vec2_t(f(a.x, b.x), f(a.y, b.y))
end
---@return vec2_t
vec2_mt.__add = function(a, b)
    return operation2(a, b, function(c, d) return c + d end) end
---@return vec2_t
vec2_mt.__sub = function(a, b)
    return operation2(a, b, function(c, d) return c - d end) end
---@return vec2_t
vec2_mt.__mul = function(a, b)
    return operation2(a, b, function(c, d) return c * d end) end
---@return vec2_t
vec2_mt.__div = function(a, b)
    return operation2(a, b, function(c, d) return c / d end) end
---@return boolean
vec2_mt.__eq = function(a, b)
    return a.x == b.x and a.y == b.y end

---@class vec3_t
---@operator mul(number|vec3_t): vec3_t
---@operator div(number|vec3_t): vec3_t
---@operator add(number|vec3_t): vec3_t
---@operator sub(number|vec3_t): vec3_t
local vec3_mt = getmetatable(vec3_t())
---@class color_t
local vec3_mt_ext = {}
local operation3 = function(a, b, f)
    if type(b) == "number" then
        return vec3_t(f(a.x, b), f(a.y, b), f(a.z, b)) end
    return vec3_t(f(a.x, b.x), f(a.y, b.y), f(a.z, b.z))
end
---@return vec3_t
vec3_mt.__add = function(a, b)
    return operation3(a, b, function(c, d) return c + d end) end
---@return vec3_t
vec3_mt.__sub = function(a, b)
    return operation3(a, b, function(c, d) return c - d end) end
---@return vec3_t
vec3_mt.__mul = function(a, b)
    return operation3(a, b, function(c, d) return c * d end) end
---@return vec3_t
vec3_mt.__div = function(a, b)
    return operation3(a, b, function(c, d) return c / d end) end
---@return boolean
vec3_mt.__eq = function(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z end

---@param a vec3_t
---@param b vec3_t
---@param t number
---@return vec3_t
vec3_mt_ext.lerp = function(a, b, t)
    ---@diagnostic disable-next-line: return-type-mismatch
    return a + (b - a) * t
end
local o_vec3_mt_index = vec3_mt.__index
vec3_mt.__index = function(s, k)
    local value = vec3_mt_ext[k]
    if value then return value end
    return o_vec3_mt_index(s, k)
end