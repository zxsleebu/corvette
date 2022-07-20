local t_misc = tabs.new("misc", {"main"})
t_misc.main:add_checkbox("alt-tab optimization", true):callback(e_callbacks.PAINT, function()
    cvars.fps_max:set_int(engine.is_app_active() and 0 or 50)
end)