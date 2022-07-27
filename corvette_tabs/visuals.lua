local t_visuals = tabs.new("visuals", {"general", "indicators", "esp", "local player"})
local widgets_font = render.create_font("Verdana", 12, 200, e_font_flags.DROPSHADOW)
local ui_animations = {
    indicators = {
        add_x = 0
    },
    widgets = {
        water = {width = 1},
        binds = {width = 1, alpha = 0},
        sdown = {width = 1, alpha = 0},
    }
}
do
    local logo_font = render.create_font("Verdana", 12, 600, e_font_flags.DROPSHADOW)
    local text_font = render.create_font("?", 8, 100, e_font_flags.DROPSHADOW)
    local add_ind = function(name, condition, color)
        return {
            name = name,
            condition = condition,
            color = color,
            anim = 0,
        }
    end
    local add_bind = function(name, reference)
        return {
            name = name,
            reference = reference,
            anim = 0,
        }
    end
    local bind_ind = function(reference)
        return function()
            return reference
        end
    end
    local ragebot_tabs = {"auto", "scout", "awp", "deagle", "revolver", "pistols", "other"}
    local get_active_weapon = function()
        return ragebot_tabs[ragebot.get_active_cfg() + 1]
    end
    local target_overrides = function(name)
        return function()
            local weapon = get_active_weapon()
            if not weapon then return end
            local el = menu.find("aimbot", weapon, "target overrides", name)
            if not el then return end
            return el[2]
        end
    end

    local m_keybinds = t_visuals.indicators:add_checkbox("keybinds", true)
    local m_keybinds_color = m_keybinds:add_color_picker("accent_color", ui.misc.main.config.accent_color:get())
    local m_keybinds_min_width = t_visuals.indicators:add_slider("minimum width", 70, 300):master(m_keybinds)
    local m_keybinds_x = t_visuals.indicators:add_slider("k_x", 0, ss.x)
    local m_keybinds_y = t_visuals.indicators:add_slider("k_y", 0, ss.y)

    m_keybinds_x:set_visible(false)
    m_keybinds_y:set_visible(false)

    local bindlist = {
        add_bind("Force hitchance", target_overrides("force hitchance")),
        add_bind("Force body lean safepoint", target_overrides("force body lean safepoint")),
        add_bind("Force lethal shot", target_overrides("force lethal shot")),
        add_bind("Force safe point", target_overrides("force safepoint")),
        add_bind("Force body aim", target_overrides("force hitbox")),
        add_bind("Minimum damage", target_overrides("force min. damage")),
        add_bind("Double tap", bind_ind(ui.aimbot.general.exploits.doubletap)),
        add_bind("Override resolver", bind_ind(ui.aimbot.general.aimbot.override_resolver)),
        add_bind("Body lean resolver", bind_ind(ui.aimbot.general.aimbot.body_lean_resolver)),
        add_bind("On shot anti-aim", bind_ind(ui.aimbot.general.exploits.hideshots)),
        add_bind("Quick peek assist", bind_ind(ui.aimbot.general.misc.autopeek)),
        add_bind("Body lean inverter", bind_ind(ui.antiaim.main.manual.invert_body_lean)),
        add_bind("Desync inverter", bind_ind(ui.antiaim.main.manual.invert_desync)),
        add_bind("Extended angles", bind_ind(ui.antiaim.main.extended_angles.enable)),
        add_bind("Freestanding", bind_ind(ui.antiaim.main.auto_direction.enable)),
        add_bind("Lock angle", bind_ind(ui.antiaim.main.general.lock_angle)),
        add_bind("Ping spike", bind_ind(ui.aimbot.general.fake_ping.enable)),
        add_bind("Slow motion", bind_ind(ui.misc.main.movement.slow_walk)),
        add_bind("Jump at edge", bind_ind(ui.misc.main.movement.edge_jump)),
        add_bind("Jump at bug", bind_ind(ui.misc.main.movement.jump_bug)),
        add_bind("Edge bug helper", bind_ind(ui.misc.main.movement.edge_bug_helper)),
        add_bind("Sneak", bind_ind(ui.misc.main.movement.sneak)),
    }

    local m_keybinds_draggable = essentials.draggable(m_keybinds_x, m_keybinds_y, vec2_t(70, 17), "keybinds")

    m_keybinds:callback(e_callbacks.PAINT, function ()
        local modes = {"[toggled]", "[holding]", "[holding off]", "[always]", "[disabled]"}
        local pos = vec2_t(m_keybinds_x:get(), m_keybinds_y:get())
        local resize = {width = 20, minwidth = 0}
        local size = vec2_t(70, 19)
        local color = m_keybinds_color:get()
        local text = "keybinds"
        local plus = 0
        local h = {}

        for i = 1, #bindlist do
            local condition = bindlist[i].reference()
            if condition ~= nil then
                local active = condition:get()
                local name = bindlist[i].name
                local mode = modes[condition:get_mode() + 1]
                bindlist[i].anim = essentials.anim(bindlist[i].anim, active and 1 or 0, 20)
                if active then h[#h+1] = i end

                if bindlist[i].anim > 0.08 then
                    local offset_y = size.y + 2 + (14 * plus)

                    render.push_alpha_modifier(bindlist[i].anim)
                    render.text(widgets_font, name, pos + vec2_t(5, offset_y), color_t(255, 255, 255, 255))
                    render.text(widgets_font, mode, pos + vec2_t(math.ceil(ui_animations.widgets.binds.width) - render.get_text_size(widgets_font, mode).x - 3, offset_y), color_t(255, 255, 255, 255))
                    render.pop_alpha_modifier()

                    plus = plus + math.ceil(bindlist[i].anim * 100) / 100

                    if render.get_text_size(widgets_font, name .. mode).x > resize.minwidth then
                        resize.minwidth = render.get_text_size(widgets_font, name .. mode).x
                    end
                end
            end
        end

        ui_animations.widgets.binds.alpha = essentials.anim(ui_animations.widgets.binds.alpha, (#h > 0 or menu.is_open()) and 1 or 0, 20)

        resize.width = resize.width + resize.minwidth
        if resize.width < m_keybinds_min_width:get() then resize.width = m_keybinds_min_width:get() end
        ui_animations.widgets.binds.width = essentials.anim(ui_animations.widgets.binds.width, resize.width)
        size.x = math.ceil(ui_animations.widgets.binds.width)

        if ui_animations.widgets.binds.alpha > 0.08 then
            render.solus_container(pos, size, color, ui_animations.widgets.binds.alpha, 3)
            render.push_alpha_modifier(ui_animations.widgets.binds.alpha)
            render.text(widgets_font, text, pos + vec2_t(size.x / 2 - render.get_text_size(widgets_font, text).x / 2, 3), color_t(255, 255, 255, 255))
            render.pop_alpha_modifier()
            m_keybinds_draggable:drag(vec2_t(ui_animations.widgets.binds.width + 2, size.y))
        end
    end)

    local indicators = {
        add_ind("DOUBLETAP", bind_ind(ui.aimbot.general.exploits.doubletap), color_t(255, 255, 255, 255)),
        add_ind("ONSHOT", bind_ind(ui.aimbot.general.exploits.hideshots), color_t(255, 255, 255, 255)),
        add_ind("BAIM", target_overrides("force hitbox"), color_t(255, 255, 255, 255)),
        add_ind(function()
            local weapon = get_active_weapon()
            if not weapon then return "DAMAGE" end
            local el = menu.find("aimbot", weapon, "target overrides", "force min. damage")
            if not el then return "DAMAGE" end
            return "DAMAGE: " .. el[1]:get()
        end, target_overrides("force min. damage"), color_t(255, 255, 255, 255)),
        add_ind("SAFEPOINT", target_overrides("force safepoint"), color_t(255, 255, 255, 255)),
    }

    local m_indicators = t_visuals.indicators:add_checkbox("under crosshair", true)
    local m_indicators_first_color = m_indicators:add_color_picker("first_color", ui.misc.main.config.accent_color:get())
    local m_indicators_second_color = m_indicators:add_color_picker("second_color", color_t(0, 0, 0, 124))

    m_indicators:callback(e_callbacks.PAINT, function ()
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then return end
        local pos = ss / 2 + vec2_t(0, 35)
        local primary_color = m_indicators_first_color:get()
        local secondary_color = m_indicators_second_color:get()
        local m_text = "~corvette~"
        ui_animations.indicators.add_x = essentials.anim(ui_animations.indicators.add_x, lp:get_prop("m_bIsScoped") == 1 and 45 or 0)

        local x = 0
        x = x - render.get_text_size(logo_font, m_text).x / 2

        for idx = 1, #m_text do
            local m_letter = m_text:sub(idx, idx)
            local m_letter_size = render.get_text_size(logo_font, m_letter)

            local alpha = idx / #m_text
            local anim = math.sin(math.abs(-math.pi + (global_vars.real_time() + alpha) * 1.4 % (math.pi * 2)))

            local color = primary_color:fade(secondary_color, anim)

            render.text(logo_font, m_letter, pos + vec2_t(x + math.ceil(ui_animations.indicators.add_x), -8), color)

            x = x + m_letter_size.x
        end

        local plus = 0
        for i = 1, #indicators do
            local ind = indicators[i]
            local condition = ind.condition()
            local active = condition and condition:get()
            local name = type(ind.name) == "function" and ind.name() or ind.name
            local size = render.get_text_size(text_font, name)

            indicators[i].anim = essentials.anim(indicators[i].anim, active and 1 or 0)
            if indicators[i].anim > 0.08 then
                if name == "DOUBLETAP" then indicators[i].color = essentials.color_anim(indicators[i].color, exploits.get_charge() > 0 and color_t(255, 255, 255, 255) or color_t(255, 0, 0, 255), 8) end
                local offset_y = 5 + (8 * plus)
                render.push_alpha_modifier(indicators[i].anim)
                render.text(text_font, name, pos + vec2_t(-size.x / 2 + math.ceil(ui_animations.indicators.add_x), offset_y), indicators[i].color)
                render.pop_alpha_modifier()
                plus = plus + math.ceil(indicators[i].anim * 100) / 100
            end
        end
    end)
end
do
    local m_watermark = t_visuals.indicators:add_checkbox("watermark", true)
    local m_watermark_color = m_watermark:add_color_picker("accent_color", ui.misc.main.config.accent_color:get())
    local watermark_entry = function (name, text)
        return {
            name = name,
            text = text,
        }
    end
    local m_show_seconds
    local watermark_entries = {
        watermark_entry("name", function()
            return user.name
        end),
        watermark_entry("fps", client.get_fps),
        watermark_entry("latency", function()
            if not engine.is_connected() then return end
            return "delay: " .. math.floor(engine.get_latency( e_latency_flows.OUTGOING ) * 999) .. "ms"
        end),
        watermark_entry("tickrate", function()
            if not engine.is_connected() then return end
            return string.format("%dtick", client.get_tickrate())
        end),
        watermark_entry("time", function()
            local hours, min, sec = client.get_local_time()
            local time = (hours < 10 and "0" .. hours or hours) .. ":" .. (min < 10 and "0" .. min or min)
            local seconds = ":" .. (sec < 10 and "0" .. sec or sec)
            if m_show_seconds:get() then
                return time .. seconds end
            return time
        end),
    }
    local watermark_entries_names = {}
    for i = 1, #watermark_entries do
        watermark_entries_names[#watermark_entries_names+1] = watermark_entries[i].name
    end
    local m_features = t_visuals.indicators:add_multi_selection("features", watermark_entries_names):master(m_watermark)
    m_show_seconds = t_visuals.indicators:add_checkbox("show seconds")

    m_watermark:callback(e_callbacks.DRAW_WATERMARK, function (watermark_text) return end)
    m_watermark:callback(e_callbacks.PAINT, function ()
        m_show_seconds:set_visible(m_features:get(5))
        local pos = vec2_t(0, 11)
        local size = vec2_t(500, 19)
        local color = m_watermark_color:get()
        local watermark_name = {"corv", "ette.lua"}
        local watermark_text = {}
        local table_text = {
            {"corv", color_t(255, 255, 255, 255)},
            {"ette.lua", color:alpha(255)},
        }
        for i = 1, #watermark_entries do
            if m_features:get(i) then
                local result = watermark_entries[i].text()
                if result then
                    table.insert(watermark_text, tostring(result))
                    table.insert(table_text, {"  " .. tostring(result), color_t(255, 255, 255, 255)})
                end
            end
        end
        local text = table.concat(watermark_text, "  ")
        if #text > 0 then
            text = "  " .. text
        end

        local textsize = render.get_text_size(widgets_font, watermark_name[1] .. watermark_name[2] .. text)

        ui_animations.widgets.water.width = essentials.anim(ui_animations.widgets.water.width, textsize.x + 9)
        size.x = math.ceil(ui_animations.widgets.water.width)
        pos.x = ss.x - size.x - 11

        render.solus_container(pos, size, color, 1, 3)
        render.multi_color_text(widgets_font, table_text, pos + vec2_t(5, 3), false, 1)
    end)
end

do
    local warning_font = render.create_font("Verdana", 32, 600, e_font_flags.ANTIALIAS)
    local m_slowed_down = t_visuals.indicators:add_checkbox("slowed down", true)
    local m_slowed_down_x = t_visuals.indicators:add_slider("sw_x", 0, ss.x)
    local m_slowed_down_y = t_visuals.indicators:add_slider("sw_y", 0, ss.y)

    m_slowed_down_x:set_visible(false)
    m_slowed_down_y:set_visible(false)

    local m_slowed_down_draggable = essentials.draggable(m_slowed_down_x, m_slowed_down_y, vec2_t(146, 37), "slowed_down")

    local color_mod = function(perc)
        local r = math.ceil(124 * 2 - 124 * perc)
        local g = math.ceil(180 * perc)
        local b = 13
        return color_t(r, g, b, 255)
    end

    m_slowed_down:callback(e_callbacks.PAINT, function ()
        local pos = vec2_t(m_slowed_down_x:get(), m_slowed_down_y:get())
        local lp = entity_list.get_local_player()
        local velmod = 1
        local size = vec2_t(98, 11)

        if lp and lp:is_alive() then
            velmod = lp:get_prop("m_flVelocityModifier")
        else
            velmod = 1
        end

        ui_animations.widgets.sdown.width = essentials.anim(ui_animations.widgets.sdown.width, velmod)

        local alpha = math.sin(math.abs(-math.pi + (global_vars.real_time() * (2 / 1)) % (math.pi)))
        local text = "Slowed down!"
        local textsize = render.get_text_size(widgets_font, text)
        local color = color_mod(ui_animations.widgets.sdown.width)
        ui_animations.widgets.sdown.alpha = essentials.anim(ui_animations.widgets.sdown.alpha, (velmod < 1 or menu.is_open()) and 1 or 0)

        if ui_animations.widgets.sdown.alpha > 0.08 then
            local size_process = math.ceil(size.x * (ui_animations.widgets.sdown.width * 100) / 100) - 1
            local velsize = render.get_text_size(widgets_font, string.format("%d%%", velmod * 100)).x + 2
            local size_x = size_process < math.ceil(velsize) and math.ceil(velsize) or size_process

            render.push_alpha_modifier(ui_animations.widgets.sdown.alpha)
            render.rect_filled(pos + vec2_t(43, textsize.y + 5), vec2_t(size.x + 1, size.y + 1), color_t(17, 17, 17, 200), 0)
            render.rect_filled(pos + vec2_t(43 + 1, textsize.y + 5 + 1), vec2_t(size_x, size.y - 1), color, 0)

            render.text(widgets_font, text, pos + vec2_t(44, 5 - 1), color_t(255, 255, 255))
            render.text(widgets_font, string.format("%d%%", velmod * 100), pos + vec2_t(43 + size_x - render.get_text_size(widgets_font, string.format("%d%%", velmod * 100)).x, 17), color_t(255, 255, 255))

            render.polygon({vec2_t(pos.x, pos.y + 35), vec2_t(pos.x + 20, pos.y), vec2_t(pos.x + 40, pos.y + 35)}, color_t(17, 17, 17, math.max(50, math.ceil(200 * alpha))))
            render.polygon({vec2_t(pos.x + 4, pos.y + 35 - 2), vec2_t(pos.x + 20, pos.y + 5), vec2_t(pos.x + 40 - 4, pos.y + 35 - 2)}, color:alpha(math.max(50, math.ceil(255 * alpha))))
            render.text(warning_font, "!", pos + vec2_t(14, 4), color_t(80, 80, 80, math.max(50, math.ceil(255 * alpha))))
            render.pop_alpha_modifier()
            m_slowed_down_draggable:drag(vec2_t(142, 35))
        end
    end)
end

do
    local logs = {}
    local m_logs_under_crosshair = t_visuals.indicators:add_checkbox("logs under crosshair", true)
    local m_accent_color = m_logs_under_crosshair:add_color_picker("accent color", color_t(148, 199, 59))
    local m_maximum_count_logs = t_visuals.indicators:add_slider("maximum count logs", 3, 17)
    m_maximum_count_logs:master(m_logs_under_crosshair)

    m_logs_under_crosshair:callback(e_callbacks.PAINT, function ()
        if not engine.is_connected() then logs = {} return end
        local pos = vec2_t(ss.x / 2, ss.y / 1.48)
        local offset_y = 0

        for i = 1, #logs do
            if logs[i] then
                local log = logs[i]

                render.multi_color_text(widgets_font, log.text_table, pos + vec2_t(math.ceil(log.x), math.ceil(offset_y)), true, log.alpha)

                offset_y = offset_y + log.y

                if log.time + 5 < global_vars.cur_time() or i > m_maximum_count_logs:get() then
                    log.alpha = essentials.anim(log.alpha, 0)
                    log.x = essentials.anim(log.x, 60, 10)
                    if log.x >= 59 then
                        table.remove(logs, i)
                    end
                else
                    log.alpha = essentials.anim(log.alpha, 1)
                    log.x = essentials.anim(log.x, 0, 10)
                    log.y = essentials.anim(log.y, 14)
                end
            end
        end
    end)

    m_logs_under_crosshair:callback(e_callbacks.EVENT, function (event)
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then return end
        if event.name ~= "player_hurt" then return end
        if entity_list.get_player_from_userid(event.attacker) ~= lp then return end

        local color = m_accent_color:get()
        local victim = entity_list.get_player_from_userid(event.userid)
        local text_table = {
            {"[", color_t(255, 255, 255, 255)},
            {"corvette.lua", color},
            {"] Hit ", color_t(255, 255, 255, 255)},
            {tostring(victim:get_name()), color},
            {" in the ", color_t(255, 255, 255, 255)},
            {hitgroups[event.hitgroup], color},
            {" for ", color_t(255, 255, 255, 255)},
            {tostring(event.dmg_health), color},
            {" damage (", color_t(255, 255, 255, 255)},
            {tostring(event.health), color},
            {" health remaining)", color_t(255, 255, 255, 255)}
        }

        table.insert(logs, 1, {text_table = text_table, x = -60, y = 0, alpha = 0, time = global_vars.cur_time()})
    end)

    local miss_color = function(reason)
        if reason == "resolver" then
            return color_t(255, 0, 0, 255)
        elseif reason == "spread" then
            return color_t(255, 199, 0, 255)
        elseif reason == "prediction error" then
            return color_t(255, 127, 127, 255)
        elseif reason == "occlusion" then
            return color_t(255, 199, 0, 255)
        end
        return color_t(214, 72, 62, 255)
    end
    local hitchance = 0
    m_logs_under_crosshair:callback(e_callbacks.AIMBOT_SHOOT, function (shot) hitchance = shot.hitchance end)
    m_logs_under_crosshair:callback(e_callbacks.AIMBOT_MISS, function (miss)
        local color = miss_color(miss.reason_string)
        local text_table = {
            {"[", color_t(255, 255, 255, 255)},
            {"corvette.lua", color},
            {"] Missed ", color_t(255, 255, 255, 255)},
            {tostring(miss.player:get_name()), color},
            {"'s ", color_t(255, 255, 255, 255)},
            {hitgroups[miss.aim_hitgroup], color},
            {" due to ", color_t(255, 255, 255, 255)},
            {miss.reason_string, color},
            {" (", color_t(255, 255, 255, 255)},
            {tostring(hitchance), color},
            {"% HC)", color_t(255, 255, 255, 255)}
        }

        table.insert(logs, 1, {text_table = text_table, x = -50, y = 0, alpha = 0, time = global_vars.cur_time()})
    end)
end

do
    local m_bullet_tracer = t_visuals.general:add_checkbox("local bullet tracer", true)
    local m_bullet_tracer_color = m_bullet_tracer:add_color_picker("color", color_t(255, 255, 255, 255))
    local m_bullet_tracer_timer = t_visuals.general:add_slider("tracer time", 1, 10)
    m_bullet_tracer_timer:master(m_bullet_tracer)
    local current_pos
    m_bullet_tracer:callback(e_callbacks.EVENT, function (event)
        if event.name == "bullet_impact" then
            local lp = entity_list.get_local_player()
            if not lp or not lp:is_alive() then return end
            if entity_list.get_player_from_userid(event.userid) ~= lp then return end
            local pos = vec3_t(event.x, event.y, event.z)
            current_pos = pos
        end
    end)

    m_bullet_tracer:callback(e_callbacks.SETUP_COMMAND, function (cmd)
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then current_pos = nil return end
        if current_pos ~= nil then
            debug_overlay.add_line(lp:get_eye_position(), current_pos, m_bullet_tracer_color:get(), true, m_bullet_tracer_timer:get())
            current_pos = nil
        end
    end)
end

local m_autopeek = t_visuals.general:add_checkbox("autopeek", true)
local m_autopeek_color_stand = m_autopeek:add_color_picker("stand", color_t(255, 255, 255))
local m_autopeek_color_return = m_autopeek:add_color_picker("return", color_t(223, 255, 143))
local m_autopeek_style = t_visuals.general:add_selection("style", {"neverlose", "gamesex"}):master(m_autopeek)
local m_autopeek_radius = t_visuals.general:add_slider("radius", 10, 30):master(m_autopeek)
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
        if not lp then return end
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
            if lp ~= nil then
                if a and a.active then
                    if lp:get_render_origin():dist(a.pos) < 20 then
                        shot = false end
                    a.fade = essentials.anim(a.fade, shot and 255 or 0)
                end
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

local m_bOnLand, m_iGroundTicks, m_flEndTime = false, 0, 0

callbacks.add(e_callbacks.SETUP_COMMAND, function()
    local lp = entity_list.get_local_player()
    if not lp then return end
    local bOnGround = not lp:is_in_air()

    if bOnGround then
        m_iGroundTicks = m_iGroundTicks + 1
    else
        m_iGroundTicks = 0
        m_flEndTime = global_vars.cur_time() + 1
    end

    m_bOnLand = false
    if m_iGroundTicks > 10 and m_flEndTime > global_vars.cur_time() then
        m_bOnLand = true
    end
end)

callbacks.add(e_callbacks.ANTIAIM, function(ctx)
    local lp = entity_list.get_local_player()
    if not lp then return end
	if m_animfucker:get(1) then
		ctx:set_render_pose(e_poses.RUN, 0)
	end
    if m_animfucker:get(4) and lp:get_velocity() > 3 then
        ctx:set_render_animlayer(e_animlayers.LEAN, 1)
    end
    if m_animfucker:get(2) then
        ctx:set_render_pose(e_poses.JUMP_FALL, 1)
    end
    if m_animfucker:get(3) and m_bOnLand then
        ctx:set_render_pose(e_poses.BODY_PITCH, 0.5)
    end
end)

local m_self_lagcomp_type
local m_self_lagcomp_render_type
local m_self_lagcomp
local m_self_lagcomp_color
do local render_types = {
    function(record, color, next_record)
        local pos = render.world_to_screen(record.origin)
        if not pos then return end
        render.circle(pos, 5, color)
    end,
    function(record, color, next_record)
        render.skeleton(record.skeleton, color)
    end,
    function(record, color, next_record)
        if not record or not next_record then return end
        local pos1, pos2 =
        render.world_to_screen(record.origin), render.world_to_screen(next_record.origin)
        if not pos1 or not pos2 then return end
        render.line(pos1, pos2, color)
    end,
}
local lerp_pos
m_self_lagcomp = t_visuals.local_player:add_checkbox("visualize local lagcomp"):callback(e_callbacks.PAINT, function()
    local lp = entity_list.get_local_player()
    if not lp or not lp:is_alive() then return end
    local records = lp:get_lagrecords()
    if not records then return end
    local render_type = m_self_lagcomp_render_type:get()
    if render_type == 3 then
        m_self_lagcomp_type:set(1)
    end
    local display_type = m_self_lagcomp_type:get()
    local renderer = render_types[render_type]
    local color = m_self_lagcomp_color:get()
    if display_type == 1 then
        for i = 1, #records do
            if render_type == 3 then
                if i == 1 then
                    if not lerp_pos then
                        lerp_pos = records[i].origin end
                    lerp_pos = lerp_pos:lerp(records[i].origin, essentials.get_anim_time(20))
                    renderer({origin = lerp_pos}, color, records[i+1])
                    elseif i == #records then
                        renderer(records[#records], color, {origin = lp:get_abs_origin()})
                    else
                        renderer(records[i], color, records[i+1])
                    end
            else
                renderer(records[i], color, records[i+1])
            end
        end
    else
        renderer(records[1], color)
    end
    if render_type == 1 then
        local origin = lp:get_abs_origin()
        local pos = render.world_to_screen(origin)
        if pos then
            render.circle(pos, 5, color_t(50, 255, 50))
        end
    end
end)
end
m_self_lagcomp_color = m_self_lagcomp:add_color_picker("color", color_t(255, 255, 255))
m_self_lagcomp_type = t_visuals.local_player:add_selection("local lagcomp type", {
    "all records",
    "last record"
}):master(m_self_lagcomp)
m_self_lagcomp_render_type = t_visuals.local_player:add_selection("local lagcomp render", {
    "circle",
    "skeleton (broken on fullscreen)",
    "line"
}):master(m_self_lagcomp)