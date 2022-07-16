require("corvette_lib/ui")
---@param s entity_t
---@param vector boolean|nil
---@return vec3_t|number
lua_entity_t.get_velocity = function(s, vector)
    local velocity = s:get_prop("m_vecVelocity") ---@type vec3_t
    if vector then
        return velocity end
    return velocity:length()
end
---@param s entity_t
---@return boolean
lua_entity_t.is_crouching = function(s)
    return s:get_prop("m_flDuckAmount") > 0
end
---@param s entity_t
---@return boolean
lua_entity_t.is_in_air = function(s)
    return bit.band(s:get_prop("m_fFlags"), 1) ~= 1
end
do local jump_key = input.find_key_bound_to_binding("jump")
---@param s entity_t
---@return "stand"|"walk"|"move"|"air"|"crouch"|nil
lua_entity_t.get_movement_type = function(s)
    local velocity = s:get_velocity()
    local crouching = s:is_crouching()
    if s:is_in_air() then
        return "air" end
    if s == entity_list.get_local_player() then
        if input.is_key_held(jump_key) then
            return "air" end
        if ui.misc.main.movement.slow_walk:get()
            and velocity > 3
            and not crouching then
            return "walk" end
        if ui.antiaim.main.general.fake_duck:get() then
            return "crouch" end
    end
    if crouching then
        return "crouch" end
    if velocity < 3 then
        return "stand" end
    if velocity > 3 then
        return "move" end
end end