tabs.setup("pantera.lua", ([[
pantera: version @BUILD_VERSION@
user: %s
build on: @BUILD_DATE@
]]):format(user.name))

require("corvette_tabs/rage")
require("corvette_tabs/antiaim")
require("corvette_tabs/visuals")
require("corvette_tabs/misc")