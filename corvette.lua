require("corvette_lib/essentials")
require("corvette_lib/tabs")
require("corvette_lib/ui")
require("corvette_lib/entity")
require("corvette_lib/globals")
require("corvette_lib/vec")
require("corvette_lib/render")
-- local inspect = require("inspect")

tabs.setup("corvette", ([[
corvette: version @BUILD_VERSION@
user: %s
build on: @BUILD_DATE@
]]):format(user.name))

local t_rage = tabs.new("rage", {"general", "misc"})
t_rage.general:add_text("no functions currently")
t_rage.misc:add_text("soon")

local t_antiaim = tabs.new("antiaim", {"general"})

m_antiaim_enable = nil
do
    local angles = ui.antiaim.main.angles
    local desync = ui.antiaim.desync
    local jitter = function()
        angles.yaw_add:set(7)
        angles.jitter_add:set(27)
        angles.jitter_mode:set(2)
        angles.jitter_type:set(2)
        angles.body_lean:set(1)
        desync.move.side:set(4)
        desync.move.left_amount:set(99)
        desync.move.right_amount:set(99)
    end
    local roll = function()
        if not essentials.get_exploit() or m_roll:get() then
            angles.yaw_add:set(0)
            angles.jitter_add:set(1)
            angles.jitter_mode:set(2)
            angles.jitter_type:set(1)

            desync.stand.left_amount:set(99)
            desync.stand.right_amount:set(99)
            desync.stand.side:set(5)

            angles.body_lean:set(m_roll:get() and 2 or 1)
            angles.body_lean_value:set(50 * (essentials.is_desync_inverted() and -1 or 1))
            angles.moving_body_lean:set(false)
            desync.move.side:set(5)
        else
            jitter()
        end
    end
    local modes = {
        stand = roll,
        move = jitter,
        walk = jitter,
        air = jitter,
        crouch = function()
            roll()
            angles.moving_body_lean:set(true)
        end,
    }
    m_antiaim_enable = t_antiaim.general:add_checkbox("enable"):callback(e_callbacks.PAINT, function()
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then return end
        local mode = lp:get_movement_type()
        if mode then
            modes[mode]() end
    end)
end
m_roll = t_antiaim.general:add_checkbox("roll"):master(m_antiaim_enable)

local t_visuals = tabs.new("visuals", {"general", "indicators", "esp"})
do
    local logo_font = render.create_font("Terminal", 14, 300, e_font_flags.OUTLINE)
    local text_font = render.create_font("Smallest Pixel-7", 11, 300, e_font_flags.OUTLINE)
    -- local add = function(name, condition)
    --     return {
    --         name = name,
    --         condition = condition,
    --         size = 0,
    --         alpha = 0,
    --     }
    -- end
    -- local bind_ind = function(reference)
    --     return function() return reference:get() end
    -- end
    -- local ragebot_tabs = {"auto", "scout", "awp", "deagle", "revolver", "pistols", "other", "general"}
    -- local get_active_weapon = function()
    --     return ragebot_tabs[ragebot.get_active_cfg() + 1]
    -- end
    -- local indicators = {
    --     add("dt", bind_ind(ui.aimbot.general.exploits.doubletap)),
    --     add("os", bind_ind(ui.aimbot.general.exploits.hideshots)),
    --     add("baim", function()
    --         return menu.find("aimbot", get_active_weapon(), "target overrides", "force hitbox")[2]:get()
    --     end),
    --     add(function()
    --         return "dmg: " .. menu.find("aimbot", get_active_weapon(), "target overrides", "force min. damage")[1]:get()
    --     end, function()
    --         return menu.find("aimbot", get_active_weapon(), "target overrides", "force min. damage")[2]:get()
    --     end),
    --     add("sp", function()
    --         return menu.find("aimbot", get_active_weapon(), "target overrides", "force safepoint")[2]:get()
    --     end),
    -- }
    t_visuals.indicators:add_checkbox("enable", true):callback(e_callbacks.PAINT, function ()
        local secondary_color = color_t(150, 150, 150)
        render.gradient_text(logo_font, "corvette", ss / 2 + vec2_t(0, 20),
            {secondary_color, color_t(255, 255, 255), secondary_color}, true,
            function(symbol, size)
                if symbol == "t" or symbol == "r" then
                    return size + 1 end
            end)
        local lp = entity_list.get_local_player()
        local mode = "*" .. (lp:get_movement_type() or "none")
        render.text(text_font, mode, ss / 2 + vec2_t(0, 30), color_t(255, 255, 255), true)
        -- local width = 0
        -- for i = 1, #indicators do
        --     width = width + indicators[i].size
        -- end
        -- local x = -width / 2
        -- for i = 1, #indicators do
        --     local ind = indicators[i]
        --     local active = ind.condition()
        --     local name = type(ind.name) == "function" and ind.name() or ind.name
        --     local size = render.get_text_size(text_font, name).x + 4
        --     indicators[i].size = essentials.anim(ind.size, active and size or 0)
        --     indicators[i].alpha = essentials.anim(ind.alpha, active and 255 or 0)
        --     render.text(text_font, name, ss / 2 + vec2_t(x + 3, 33), color_t(255, 255, 255, math.ceil(ind.alpha)))
        --     x = x + math.ceil(indicators[i].size)
        -- end
    end)
end
t_visuals.general:add_text("no functions currently")
t_visuals.esp:add_text("soon")

local t_misc = tabs.new("misc", {"main"})
t_misc.main:add_checkbox("alt-tab optimization", true):callback(e_callbacks.PAINT, function()
    cvars.fps_max:set_int(engine.is_app_active() and 0 or 50)
end)

callbacks.add(e_callbacks.PAINT, function()
    tabs.handler()
    elements.handler()
end)
