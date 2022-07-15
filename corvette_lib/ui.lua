ui = {
    antiaim = {
        angles = {
            yaw_add = 0,
            jitter_mode = 0,
            jitter_type = 0,
            jitter_add = 0,
        },
        desync = {
            __reference = {
                override_stand = 0,
                side = 0,
                left_amount = 0,
                right_amount = 0,
            },
            stand = {},
            move = {},
            slow_walk = {}
        }
    }
}
for k, _ in pairs(ui.antiaim.angles) do
    ---@diagnostic disable-next-line: assign-type-mismatch
    ui.antiaim.angles[k] = menu.find("antiaim", "main", "angles", k:gsub("_", " "))
end
for _, mode in pairs({"stand", "move", "slow_walk"}) do
    for k, _ in pairs(ui.antiaim.desync.__reference) do
        ---@diagnostic disable-next-line: assign-type-mismatch
        ui.antiaim.desync[mode][k] =
            menu.find("antiaim", "main", "desync", k:gsub("_", " ").."#"..mode:gsub("_", " "))
    end
end