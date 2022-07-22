local t_visuals = tabs.new("visuals", {"general", "indicators", "esp", "local player"})
do
    local logo_font = render.create_font("Verdana", 12, 600, e_font_flags.DROPSHADOW)
    local text_font = render.create_font("Smallest Pixel-7", 8, 100, e_font_flags.DROPSHADOW)
    local add = function(name, condition)
        return {
            name = name,
            condition = condition,
            size = 0,
            alpha = 0,
            margin = 0,
            active = false,
        }
    end
    local bind_ind = function(reference)
        return function() return reference:get() end
    end
    local ragebot_tabs = {"auto", "scout", "awp", "deagle", "revolver", "pistols", "other", "general"}
    local get_active_weapon = function()
        return ragebot_tabs[ragebot.get_active_cfg() + 1]
    end
    local target_overrides = function(name)
        return function()
            local weapon = get_active_weapon()
            if not weapon then return end
            local el = menu.find("aimbot", weapon, "target overrides", name)
            if not el then return end
            return el[2]:get()
        end
    end

    local m_widgets = t_visuals.indicators:add_multi_selection("widgets", {"watermark", "keybinds", "spectators", "slowed down"})

    local indicators = {
        add("DT", bind_ind(ui.aimbot.general.exploits.doubletap)),
        add("OS", bind_ind(ui.aimbot.general.exploits.hideshots)),
        add("BAIM", target_overrides("force hitbox")),
        add(function()
            local weapon = get_active_weapon()
            if not weapon then return "DMG" end
            local el = menu.find("aimbot", weapon, "target overrides", "force min. damage")
            if not el then return "DMG" end
            return "DMG: " .. el[1]:get()
        end, target_overrides("force min. damage")),
        add("SP", target_overrides("force safepoint")),
    }

    local ind_add_x = 0
    local m_indicators = t_visuals.indicators:add_checkbox("indicators under crosshair", true)
    local m_indicators_color = m_indicators:add_color_picker("color", ui.misc.main.config.accent_color:get())

    m_indicators:callback(e_callbacks.PAINT, function ()
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then return end
        local pos = ss / 2 + vec2_t(0, 35)
        local primary_color = m_indicators_color:get()
        local secondary_color = color_t(0, 0, 0, 80)
        local m_text = "pantera" 
        ind_add_x = essentials.anim(ind_add_x, lp:get_prop("m_bIsScoped") == 1 and 30 or 0)

        local x = 0
        x = x - render.get_text_size(logo_font, m_text).x / 2

        for idx = 1, #m_text do
            local m_letter = m_text:sub(idx, idx);
            local m_letter_size = render.get_text_size(logo_font, m_letter);
        
            local alpha = idx / #m_text;
            local anim = math.sin(math.abs(-math.pi + (global_vars.real_time() + alpha) * 1.4 % (math.pi * 2)))
            
            local color = essentials.color_lerp(primary_color, secondary_color, anim)

            render.text(logo_font, m_letter, pos + vec2_t(x + math.ceil(ind_add_x), -8), color)

            x = x + m_letter_size.x;
        end

        local movement_type = lp:get_movement_type() or "NONE"
        local mode = "~" .. movement_type .. "~"
        render.text(text_font, string.upper(mode), pos + vec2_t(-render.get_text_size(text_font, string.upper(mode)).x / 2 + math.ceil(ind_add_x), 5), primary_color)

        --yeah, this is ugly, but it works
        --waiting for senry to rewrite this shit ass code
        local width = 0
        local margin = 4
        local last_active_was_parsed = false
        for i = #indicators, 1, -1 do
            local last_active = false
            width = width + indicators[i].size
            indicators[i].active = indicators[i].condition()
            if indicators[i].active and not last_active_was_parsed then
                last_active_was_parsed = true
                last_active = true
            end
            indicators[i].margin =
                essentials.anim(indicators[i].margin, (indicators[i].active and not last_active) and margin or 0)
            
        end
        local y = 0
        for i = 1, #indicators do
            local ind = indicators[i]
            local err, active = pcall(ind.condition)
            local name = type(ind.name) == "function" and ind.name() or ind.name
            local size = render.get_text_size(text_font, name)
            indicators[i].size = essentials.anim(ind.size, active and size.y - 1 or 0)
            indicators[i].alpha = essentials.anim(ind.alpha, active and 255 or 0)
            if indicators[i].size >= 1 and indicators[i].alpha >= 1 then
                render.text(text_font, name, pos + vec2_t(-size.x / 2 + math.ceil(ind_add_x), 14 + y), color_t(255, 255, 255, math.ceil(ind.alpha)))
                y = y + math.ceil(indicators[i].size)
            end
        end
    end)
end

local m_autopeek = t_visuals.general:add_checkbox("autopeek", true)
local m_autopeek_color_stand = m_autopeek:add_color_picker("stand", color_t(255, 255, 255))
local m_autopeek_color_return = m_autopeek:add_color_picker("return", color_t(223, 255, 143))
local m_autopeek_style = t_visuals.general:add_selection("style", {"neverlose", "gamesex"})
local m_autopeek_radius = t_visuals.general:add_slider("radius", 10, 30):master(m_autopeek)
m_autopeek_style:master(m_autopeek)
do
    local col = ui.aimbot.general.misc.autopeek_mode:get()
    m_autopeek_color_stand:set(col:alpha(m_autopeek_color_stand:get().a))
    ui.aimbot.general.misc.autopeek_mode:set(col:alpha(0))
end
do
    local autopeeks = {}
    local autopeek_mode = menu.find("aimbot", "general", "misc", "autopeek mode")[1]
    local movement_buttons = {
        moveright = 0,
        moveleft = 0,
        back = 0,
        forward = 0,
    }
    for k, _ in pairs(movement_buttons) do
        movement_buttons[k] = input.find_key_bound_to_binding(k)
    end
    local shot = false
    m_autopeek:callback(e_callbacks.SETUP_COMMAND, function()
        local lp = entity_list.get_local_player()
        if autopeek_mode:get() == 2 then return end
        local active = false
        if lp:get_velocity() > 5 then
            active = true end
        for _, v in pairs(movement_buttons) do
            if input.is_key_held(v) then active = false end
        end
        if shot then active = true end
        local a = autopeeks[#autopeeks]
        if a and a.active then
            if lp:get_render_origin():dist(a.pos) < 20 then
                active, shot = false, false
            end
            a.fade = essentials.anim(a.fade, active and 255 or 0)
        end
    end)
    m_autopeek:callback(e_callbacks.EVENT, function (event)
        if event.name ~= "weapon_fire" then return end
        if entity_list.get_player_from_userid(event.userid) ~= entity_list.get_local_player() then return end
        shot = true
    end)
    m_autopeek:callback(e_callbacks.PAINT, function()
        local pos = ragebot.get_autopeek_pos()
        local active = ui.aimbot.general.misc.autopeek:get()
        local col_stand = m_autopeek_color_stand:get() ---@type color_t
        local col_return = m_autopeek_color_return:get() ---@type color_t
        local radius = m_autopeek_radius:get()
        if autopeek_mode:get() == 2 then
            local lp = entity_list.get_local_player()
            local a = autopeeks[#autopeeks]
            if a and a.active then
                if lp:get_render_origin():dist(a.pos) < 20 then
                    shot = false end
                a.fade = essentials.anim(a.fade, shot and 255 or 0)
            end
        end

        local render_circle = render.circle_3d
        if m_autopeek_style:get() == 2 then
            render_circle = function (pos, points, radius, in_col, out_col)
                local step = 0.04
                points = radius * 1.5
                local color = in_col:alpha(math.ceil(in_col.a / 10))
                for i = 0.1, 1, step do
                    render.circle_3d(pos, clamp(points * i, 15, points), radius * i, color:alpha(math.ceil(color.a / i)))
                end
            end
        end

        local included = false
        for i = 1, #autopeeks do
            pcall(function()
                local a = autopeeks[i]
                if not a then return end
                if not active then
                    a.active = false end
                if a.pos == pos and a.active then
                    included = true end
                a.alpha = essentials.anim(a.alpha, a.active and 255 or 0)
                a.radius = essentials.anim(a.radius, a.active and radius or 0)
                local col = col_stand:fade(col_return, a.fade / 255)
                render_circle(a.pos,
                    50,
                    math.ceil(a.radius * 10) / 10,
                    col:alpha(math.ceil(a.alpha / 3)),
                    col:alpha(math.ceil(a.alpha))
                )
                if a.alpha <= 1 or a.radius <= 1 then
                    table.remove(autopeeks, i) end
            end)
        end
        if not included and pos then
            table.insert(autopeeks, {
                active = true,
                pos = pos,
                alpha = 0,
                radius = 0,
                fade = 0,
            })
        end
    end)
end

t_visuals.esp:add_text("soon")
local m_animfucker = t_visuals.local_player:add_multi_selection("animfix corrector", {
    "reversed legs",
    "static legs in air",
    "pitch 0 on land",
    "body leaning"
})
callbacks.add(e_callbacks.ANTIAIM, function(ctx)
    local lp = entity_list.get_local_player()
	if m_animfucker:get(1) then
		ctx:set_render_pose(e_poses.RUN, 0)
	end
    if m_animfucker:get(4) and lp:get_velocity() > 3 then
        ctx:set_render_animlayer(e_animlayers.LEAN, 1)
    end
    if m_animfucker:get(2) then
        ctx:set_render_pose(e_poses.JUMP_FALL, 1)
    end
end)