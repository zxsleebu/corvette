ffp = {}
local interface_t = {
    ---@class interface_t
    __index = {
        ---@type fun(self: interface_t, cast: string|ffi.ctype*|ffi.cdecl*, index: number): fun(...)
        get_vfunc = function(self, cast, index)
            return function(...)
                return ffi.cast(cast, self.vtable[0][index])(self.pointer, ...)
            end
        end,
    }
}
---@return interface_t
ffp.create_interface = function(module, name)
    local interface = memory.create_interface(module .. ".dll", name) or error("failed to create interface " .. name)
    local vtable = ffi.cast("void***", interface)
    local t = {
        vtable = vtable,
        pointer = ffi.cast("void*", interface),
    }
    setmetatable(t, interface_t)
    return t
end