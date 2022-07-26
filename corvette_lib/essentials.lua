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

local widgets = {}

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
        return global_vars.absolute_frame_time() * (speed or 14)
    end,
    anim = function(a, b, t)
        t = essentials.get_anim_time(t)
        return a + (b - a) * t
    end,
    color_anim = function(color_a, color_b, timer)
        return color_t(
            math.floor(essentials.anim(color_a.r, color_b.r, timer)),
            math.floor(essentials.anim(color_a.g, color_b.g, timer)),
            math.floor(essentials.anim(color_a.b, color_b.b, timer)),
            math.floor(essentials.anim(color_a.a, color_b.a, timer))
        )
    end,
    percent_lerp = function(x, v, t)
        local delta = v - x;
        if type(delta) == 'number' then
            if math.abs(delta) < 0.005 then
                return v
            end
        end
      
        return delta * t + x
    end,
    color_percent = function(clr1, clr2, percent)
        return color_t(
            math.floor(essentials.percent_lerp(clr1.r, clr2.r, percent)),
            math.floor(essentials.percent_lerp(clr1.g, clr2.g, percent)),
            math.floor(essentials.percent_lerp(clr1.b, clr2.b, percent)),
            math.floor(essentials.percent_lerp(clr1.a, clr2.a, percent))
        )
    end,
    draggable = function(x, y, size, name)
        return {
            position_x = x,
            position_y = y,
            size_x = size.x,
            size_y = size.y,
            started_dragging = false,
            initial_drag_pos = vec2_t(0, 0),
            drag = function (self, size)
                self.size_x = size.x or self.size_x
                self.size_y = size.y or self.size_y
                if menu.is_open() then
                    local mouse_position = input.get_mouse_pos()
                    local in_bounds = input.is_mouse_in_bounds(vec2_t(self.position_x:get(), self.position_y:get()), vec2_t(self.size_x, self.size_y))
                    if (in_bounds or self.started_dragging) and input.is_key_held(e_keys.MOUSE_LEFT) and (widgets.mouse_target == "" or widgets.mouse_target == name) then
                        widgets.mouse_target = name
                        render.rect_filled(vec2_t(self.position_x:get(), self.position_y:get()), vec2_t(self.size_x, self.size_y), color_t(255, 255, 255, 50))
                        if not self.started_dragging then
                            self.started_dragging = true
                            self.initial_drag_pos = vec2_t(mouse_position.x - self.position_x:get(), mouse_position.y - self.position_y:get())
                        else
                            self.position_x:set(math.ceil(mouse_position.x - self.initial_drag_pos.x))
                            self.position_y:set(math.ceil(mouse_position.y - self.initial_drag_pos.y))
                        end
                    elseif not input.is_key_held(e_keys.MOUSE_LEFT) then
                        widgets.mouse_target = ""
                        self.started_dragging = false
                        self.initial_drag_pos = vec2_t(0, 0)
                    end
                end
            end,
        }
    end
}

clamp = function(val, min, max) return math.max(min, math.min(max, val)) end
math.round = function(a) return math.floor(a + 0.5) end

---@param time number
---@return number
engine.time_to_ticks = function(time)
    return math.round(time / global_vars.interval_per_tick())
end
---@param ticks number
---@return number
engine.tick_to_time = function (ticks)
    return ticks * global_vars.interval_per_tick()
end