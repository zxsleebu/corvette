local get_name = function(name)
    return name:gsub("_", " ") end
local prepare_elements = function(tab, subtab)
    for group_name, _ in pairs(ui[tab][subtab]) do
        for element_name, _ in pairs(ui[tab][subtab][group_name]) do
            local elem = menu.find(tab, subtab, (group_name == "auto_direction" or group_name == "fake_ping" or group_name == "extended_angles") and get_name(group_name) or group_name, get_name(element_name))
            ---@diagnostic disable-next-line: need-check-nil
            ui[tab][subtab][group_name][element_name] = elem[2] or elem[1] or elem
        end
    end
end
ui = {
    aimbot = {
        general = {
            fake_ping = {
                enable = 0,
            },
            ---@type table<string, keybind_t>
            exploits = {
                doubletap = 0,
                dont_use_charge = 0,
                hideshots = 0,
            },
            ---@type table<string, keybind_t>
            aimbot = {
                body_lean_resolver = 0,
                override_resolver = 0,
            },
            misc = {
                autopeek = 0,
                autopeek_mode = 0,
            }
        }
    },
    antiaim = {
        ---@type table<string, __antiaim_desync_reference_t>
        desync = {
            stand = {},
            move = {},
            slow_walk = {},
            ---@class __antiaim_desync_reference_t
            __reference = {
                ---@type slider_t
                override_stand = 0,
                ---@type slider_t
                side = 0,
                ---@type slider_t
                left_amount = 0,
                ---@type slider_t
                right_amount = 0,
            },
        },
        ---@type table<string, table<string, keybind_t>>
        main = {
            ---@type table<string, slider_t>
            angles = {
                yaw_add = 0,
                jitter_mode = 0,
                jitter_type = 0,
                jitter_add = 0,
                ---@type checkbox_t
                body_lean = 0,
                body_lean_value = 0,
                ---@type checkbox_t
                moving_body_lean = 0,
            },
            general = {
                fake_duck = 0,
                lock_angle = 0,
            },
            manual = {
                invert_desync = 0,
                invert_body_lean = 0,
            },
            extended_angles = {
                enable = 0,
            },
            auto_direction = {
                enable = 0,
            },
        }
    },
    misc = {
        main = {
            movement = {
                slow_walk = 0,
                edge_jump = 0,
                sneak = 0,
                edge_bug_helper = 0,
                jump_bug = 0,
            },
            config = {
                accent_color = 0,
            },
        },
        utility = {
            general = {
                fire_extinguisher = 0,
                freecam = 0,
            }
        }
    }
}
for _, mode in pairs({"stand", "move", "slow_walk"}) do
    for k, _ in pairs(ui.antiaim.desync.__reference) do
        ---@diagnostic disable-next-line: assign-type-mismatch
        ui.antiaim.desync[mode][k] =
            menu.find("antiaim", "main", "desync", get_name(k).."#"..get_name(mode))
    end
end
prepare_elements("aimbot", "general")
prepare_elements("antiaim", "main")
prepare_elements("misc", "main")
prepare_elements("misc", "utility")