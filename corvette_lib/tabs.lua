tabs = {
    list = {},
    __group_mt = {
        __index = function(s, name)
            if name:sub(1, 4) == "add_" then
                return function(group, elem_name, ...)
                    local elem = elements.new(menu[name](group.menu_name, elem_name, ...))
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
    new = function(name, groups)
        local tab = {
            name = name,
            groups = {},
        }
        for _, group in ipairs(groups) do
            tab.groups[group] = {
                name = group,
                elements = {},
                tab = tab,
                menu_name = tab.name .. " > " .. group,
            }
            setmetatable(tab.groups[group], tabs.__group_mt)
            menu.set_group_column(tab.groups[group].menu_name, 2)
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
        },
        __index = function(s, name)
            local raw = rawget(elements.mt.__rawindex, name)
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
    new = function(el)
        local elem = {
            el = el
        }
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
        end
    end
}