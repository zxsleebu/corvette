local get_name = function(name)
    return name:gsub("_", " ") end
local prepare_elements = function(tab, subtab)
    for group_name, _ in pairs(ui[tab][subtab]) do
        for element_name, _ in pairs(ui[tab][subtab][group_name]) do
            local elem = menu.find(tab, subtab, group_name, get_name(element_name))
            ---@diagnostic disable-next-line: assign-type-mismatch, need-check-nil
            ui[tab][subtab][group_name][element_name] = elem[2] or elem[1] or elem
        end
    end
end
ui = {
    aimbot = {
        general = {
            exploits = {
                doubletap = 0,
                hideshots = 0,
            }
        }
    },
    antiaim = {
        desync = {
            ---@class __antiaim_desync_reference_t
            stand = {},
            ---@class __antiaim_desync_reference_t
            move = {},
            ---@class __antiaim_desync_reference_t
            slow_walk = {},
            ---@class __antiaim_desync_reference_t
            __reference = {
                override_stand = 0,
                side = 0,
                left_amount = 0,
                right_amount = 0,
            },
        },
        main = {
            angles = {
                yaw_add = 0,
                jitter_mode = 0,
                jitter_type = 0,
                jitter_add = 0,
                body_lean = 0,
                body_lean_value = 0,
                moving_body_lean = 0,
            },
            general = {
                fake_duck = 0,
            }
        }
    },
    misc = {
        main = {
            movement = {
                slow_walk = 0
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