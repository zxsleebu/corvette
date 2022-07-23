local t_antiaim = tabs.new("antiaim", {"general", "conditions"})

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
        desync.stand.side:set(4)
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
        fakeduck = function()
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

t_antiaim.conditions:add_text("soon"):master(m_antiaim_enable)