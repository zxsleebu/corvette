---@class element_t
---@field el userdata
---@field type string
local element_t = {
    ---@generic T
    ---@param self T
    ---@param master element_t
    ---@return T
    master =  function(self, master) end,
    ---@generic T
    ---@param self T
    ---@param type e_callbacks
    ---@param fn fun(...)
    ---@return T
    callback =  function(self, type, fn) end,
    ---@generic T
    ---@param self T
    ---@param fn fun(el: T)
    ---@return T
    change = function(self, fn) end,
}

---@class checkbox_t : element_t
---@class slider_t : element_t
---@class button_t : element_t
---@class text_t : element_t
---@class list_t : element_t
---@class text_input_t : element_t
---@class multi_selection_t : element_t
---@class selection_t : element_t

---@class tab_t
---@field add_checkbox fun(self: tab_t, name: string, default_value?: boolean): checkbox_t
---@field add_slider fun(self: tab_t, name: string, min: number, max: number, step?: number, precision?: number, suffix?: string): slider_t
---@field add_list fun(self: tab_t, name: string, items: string[], visible_items?: number): list_t
---@field add_text_input fun(self: tab_t, name: string): text_input_t
---@field add_separator fun(self: tab_t)
---@field add_button fun(self: tab_t, name: string, callback: fun(...)): button_t
---@field add_multi_selection fun(self: tab_t, name: string, items: string[], visible_items?: number): multi_selection_t
---@field add_selection fun(self: tab_t, name: string, items: string[], visible_items?: number): selection_t
---@field add_text fun(self: tab_t, name: string): text_t
tabs = {
    list = {},
    __group_mt = {
        __index = function(s, name)
            if name:sub(1, 4) == "add_" then
                return function(group, elem_name, ...)
                    local elem = elements.new(menu[name](group.menu_name, elem_name, ...), name:sub(5))
                    elem.name = elem_name
                    group.elements[#group.elements+1] = elem
                    return elem
                end
            end
        end,
    },
    __tab_mt = {
        __index = function(s, name)
            local group = s.groups[name]
            if group then return group end
            return rawget(s, name)
        end,
    },
    ---@param name string
    ---@param groups string[]
    ---@return table<string, tab_t>
    new = function(name, groups)
        local tab = {
            name = name,
            groups = {},
        }
        for _, group in ipairs(groups) do
            local g = group:gsub(" ", "_")
            tab.groups[g] = {
                name = group,
                elements = {},
                tab = tab,
                menu_name = tab.name .. " > " .. group,
            }
            setmetatable(tab.groups[g], tabs.__group_mt)
            menu.set_group_column(tab.groups[g].menu_name, 2)
        end
        setmetatable(tab, tabs.__tab_mt)
        local elements = tabs.switcher:get_items()
        elements[#elements+1] = tab.name
        tabs.switcher:set_items(elements)
        tabs.list[#tabs.list+1] = tab
        return tab
    end,
    setup = function(name, text)
        tabs.switcher = menu.add_selection(name, "tab switcher", {})
        menu.set_group_column(name, 1)
        menu.add_separator(name)
        local texts = string.split(text, "\n")
        for _, t in ipairs(texts) do
            if #t > 0 then
                menu.add_text(name, t) end
        end
    end,
    handler = function()
        local active = tabs.switcher:get()
        for i = 1, #tabs.list do
            local visibility = i == (active)
            for _, group in pairs(tabs.list[i].groups) do
                menu.set_group_visibility(group.menu_name, visibility)
            end
        end
    end
}
elements = {
    list = {},
    changeable_types = set{"checkbox", "slider"},
    mt = {
        __rawindex = {
            master = function(s, elem)
                s.master_element = elem
                return s
            end,
            _check_master = function(s)
                local val = s.el:get()
                if val and s.master_element then
                    return s.master_element:_check_master()
                end
                return val
            end,
            check_master = function (s)
                return s.master_element and s.master_element:_check_master() or not s.master_element
            end,
            callback = function(s, callback_type, func)
                callbacks.add(callback_type, function(...)
                    if s:get() and s:check_master() then
                        func(...)
                    end
                end)
                return s
            end,
            change = function(s, func)
                if elements.changeable_types[s.type] then
                    s.change_callback = func
                    func(s)
                end
                return s
            end
        },
        __index = function(s, name)
            local raw = rawget(elements.mt.__rawindex, name)
            if name:sub(1, 4) == "add_" then
                return function(elem, ...)
                    local el = elements.new(s.el[name](elem.el, ...), name:sub(5))
                    if s.type == "checkbox" then el:master(s) end
                    return el
                end
            end
            if not raw then
                if s.el[name] then
                    return function(elem, ...)
                        return elem.el[name](elem.el, ...)
                    end
                end
            end
            return raw
        end,
    },
    new = function(el, elem_type)
        local elem = {
            el = el,
            type = elem_type
        }
        if elements.changeable_types[elem.type] then
            elem.old_value = elem.el:get()
        end
        setmetatable(elem, elements.mt)
        elements.list[#elements.list+1] = elem
        return elem
    end,
    handler = function ()
        for i = 1, #elements.list do
            local elem = elements.list[i]
            if elem.master_element then
                elem:set_visible(elem:check_master())
            end
            if elem.old_value ~= nil then
                local value = elem.el:get()
                if value ~= elem.old_value then
                    elem.old_value = value
                    if elem.change_callback then
                        elem:change_callback()
                    end
                end
            end
        end
    end
}
callbacks.add(e_callbacks.SHUTDOWN, function()
    for i = 1, #elements.list do
        local elem = elements.list[i]
        if elem.change_callback and elem.type == "checkbox" then
            elem:set(false)
            elem:change_callback()
        end
    end
end)