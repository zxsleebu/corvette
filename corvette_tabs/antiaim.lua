local conditions = {"shared", "standing", "walking", "running", "air", "air duck"}
local t_antiaim = tabs.new("antiaim", {"general"})

local aa_enable = t_antiaim.general:add_checkbox("enable aa builder")
local aa_condition = t_antiaim.general:add_selection("condition", conditions):master(aa_enable)

local antiaim_settings = {}
---@param group group_t
local add_state = function(group, name)
    local s = {}
    if name ~= "shared" then
        s.override = group:add_checkbox("override")
        group:add_button("copy from shared", function()
            local c = antiaim_settings.shared
            for i = 1, #c.options:get_items() do
                s.options:set(i, c.options:get(i))
            end
            s.desync_based_yaw:set(c.desync_based_yaw:get())
            s.yaw_left:set(c.yaw_left:get())
            s.yaw_right:set(c.yaw_right:get())
            s.desync:set(c.desync:get())
            s.desync_left:set(c.desync_left:get())
            s.desync_right:set(c.desync_right:get())
            s.jitter_type:set(c.jitter_type:get())
            s.jitter_offset:set(c.jitter_offset:get())
        end):master(s.override)
    end
    s.options = group:add_multi_selection("options", {"desync jitter"}):master(s.override)
    s.desync_based_yaw = group:add_checkbox("yaw inverts with desync")
    s.yaw_left = group:add_slider("yaw offset left", -180, 180):master(s.override)
    s.yaw_right = group:add_slider("yaw offset right", -180, 180):master(s.override)
    s.desync = group:add_slider("desync delta", -100, 100)
    s.desync_left = group:add_slider("desync delta left", -100, 100)
    s.desync_right = group:add_slider("desync delta right", -100, 100)
    s.jitter_type = group:add_selection("jitter type", {"none", "offset", "offset sided", "center"})
    s.jitter_offset = group:add_slider("jitter offset", -180, 180)
    callbacks.add(e_callbacks.PAINT, function ()
        local desync_jitter = s.options:get("desync jitter")
        local enable = (s.override and s.override:get() or not s.override)
        s.desync_based_yaw:set_visible(desync_jitter and enable)
        s.desync:set_visible(enable and not desync_jitter)
        s.desync_left:set_visible(enable and desync_jitter)
        s.desync_right:set_visible(enable and desync_jitter)
        s.jitter_type:set_visible(enable)
        s.jitter_offset:set_visible(enable and s.jitter_type:get() ~= 1)
    end)
    antiaim_settings[name] = s
end
local antiaim_groups = {} ---@type table<string, group_t>
for i = 1, #conditions do
    local condition = conditions[i]
    antiaim_groups[condition] = t_antiaim:add_group("[" .. condition .. "]")
    antiaim_groups[condition].skip_visibility = true
    antiaim_groups[condition].state_id = i
    add_state(antiaim_groups[condition], condition)
    menu.set_group_column(antiaim_groups[condition].menu_name, 2)
end

callbacks.add(e_callbacks.PAINT, function()
    local current = aa_condition:get()
    local enabled = aa_enable:get()
    for i = 1, #conditions do
        local condition = antiaim_groups[conditions[i]]
        ---@diagnostic disable-next-line: undefined-field
        local active = current == condition.state_id and tabs.switcher:get() == t_antiaim.index and enabled
        menu.set_group_visibility(condition.menu_name, active)
    end
end)