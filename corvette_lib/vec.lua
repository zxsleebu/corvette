---@class vec2_t
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
local vec3_mt = getmetatable(vec3_t())
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