require("corvette_lib/init")
require("corvette_tabs/init")

callbacks.add(e_callbacks.PAINT, function()
    tabs.handler()
    elements.handler()
end)