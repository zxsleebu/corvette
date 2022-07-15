require("corvette_lib/essentials")
require("corvette_lib/tabs")
require("corvette_lib/ui")

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
    local modes = {
        stand = function()
            
        end,
    }
    m_antiaim_enable = t_antiaim.general:add_checkbox("enable"):callback(e_callbacks.ANTIAIM, function()
        local lp = entity_list.get_local_player()
        if not lp or not lp:is_alive() then return end
    end)
end
m_roll = t_antiaim.general:add_checkbox("roll"):master(m_antiaim_enable)

callbacks.add(e_callbacks.PAINT, function()
    tabs.handler()
    elements.handler()
end)
