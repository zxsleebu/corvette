require("corvette_lib/essentials")

do local get_color = function (colors, amount)
    local val = amount * (#colors - 1)
    local first_color = colors[math.floor(val) + 1]
    local second_color = colors[math.ceil(val) + 1]
    return first_color:fade(second_color, val - math.floor(val))
end
---@param font_object font_t
---@param text string
---@param screen_pos vec2_t
---@param colors color_t[]
---@param centered boolean
---@param letter_spacing function
render.gradient_text = function(font_object, text, screen_pos, colors, centered, letter_spacing)
    local x = 0
    local text_size = render.get_text_size(font_object, text)
    local offset = 0
    if centered then
        offset = math.floor(text_size.x / 2) - 2 end
    for i = 1, #text do
        local symbol = text:sub(i, i)
        local size = render.get_text_size(font_object, symbol).x
        if letter_spacing then
            local result = letter_spacing(symbol, size)
            if result then
                size = result end
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        local pos = screen_pos + vec2_t(x - offset, 0) ---@type vec2_t
        local color = get_color(colors, clamp(x / text_size.x, 0, 1))
        render.text(font_object, symbol, pos, color, centered)
        x = math.ceil(x + size)
    end
end end
---@param font_object font_t
---@param text_table table
---@param screen_pos vec2_t
---@param centered boolean
---@param alpha_modifier number
render.multi_color_text = function(font_object, text_table, screen_pos, centered, alpha_modifier)
    if centered then
        local str = ""
        for _, data in pairs(text_table) do
            str = str..string.format("%s", data[1]) end
        screen_pos.x = screen_pos.x - render.get_text_size(font_object, str).x / 2
    end
    local x = 0
    for _, data in pairs(text_table) do
        local pos = vec2_t(screen_pos.x + x, screen_pos.y) ---@type vec2_t
        render.push_alpha_modifier(alpha_modifier)
        render.text(font_object, string.format("%s", data[1]), pos, data[2])
        render.pop_alpha_modifier()
        x = x + render.get_text_size(font_object, string.format("%s", data[1])).x
    end
end

---@param center_position vec2_t
---@param start_angle number
---@param end_angle number
---@param segments number
---@param radius number
---@param width number
---@param color_arc color_t
render.arc = function (center_position, start_angle, end_angle, segments, radius, width, color_arc)
    start_angle, end_angle = start_angle * (math.pi / 180), end_angle * (math.pi / 180)

    local rotation = start_angle
    local step = 0.1 + (2 * math.pi) / segments

    while rotation < end_angle - 0.01 do
        local rotation_sin, rotation_cos = math.sin(rotation), math.cos(rotation)
        local next_rotation_sin, next_rotation_cos = math.sin(rotation + step), math.cos(rotation + step)

        local position = vec2_t(radius * rotation_cos + center_position.x, radius * rotation_sin + center_position.y)
        local next_position = vec2_t(radius * next_rotation_cos + center_position.x, radius * next_rotation_sin + center_position.y)

        local width_position = vec2_t((radius + width) * rotation_cos + center_position.x, (radius + width) * rotation_sin + center_position.y)
        local width_next_position = vec2_t((radius + width) * next_rotation_cos + center_position.x, (radius + width) * next_rotation_sin + center_position.y)

        if position.x ~= nil then
            render.polygon({position, width_position, width_next_position, next_position}, color_arc)
        end

        rotation = rotation + (step - 0.1)
    end
end

---@param pos vec2_t
---@param size vec2_t
---@param c color_t
---@param alpha number
---@param rounding number
render.solus_container = function (pos, size, c, alpha, rounding, glow)
    local o = 16

    render.push_alpha_modifier(alpha)
    render.rect_filled(vec2_t(pos.x + 1, pos.y + 1), vec2_t(size.x - 1, size.y - 2), color_t(17, 17, 17, c.a), rounding + 0.1)
    render.rect_filled(vec2_t(pos.x + rounding, pos.y), vec2_t(size.x - rounding * 2, 1), c:alpha(255)) -- up line
    render.rect_filled(vec2_t(pos.x + rounding + 1, pos.y + size.y - 1), vec2_t(size.x - rounding * 2 - 2, 1), c:alpha(50)) -- down line
    render.rect_fade(vec2_t(pos.x, pos.y + rounding + 1), vec2_t(1, size.y - rounding * 2 - 1), c:alpha(255), c:alpha(100))  -- left side
    render.rect_fade(vec2_t(pos.x + size.x, pos.y + rounding + 1), vec2_t(1, size.y - rounding * 2 - 1), c:alpha(255), c:alpha(100)) -- right side
    render.arc(vec2_t(pos.x + rounding + 1, pos.y + rounding + 1), 172, 252, 20, rounding, 1, c:alpha(255)) -- left up
    render.arc(vec2_t(pos.x + size.x - rounding, pos.y + rounding + 1), 270, 357, 20, rounding, 1, c:alpha(255)) -- right up
    render.arc(vec2_t(pos.x + rounding + 1, pos.y + size.y - rounding - 1), 88, 150, 20, rounding, 1, c:alpha(50)) -- left down
    render.arc(vec2_t(pos.x + size.x - rounding, pos.y + size.y - rounding - 1), 15, 98, 20, rounding, 1, c:alpha(50)) -- right down
    render.pop_alpha_modifier()
    if glow then
        for rad = 4, math.ceil(alpha * o) do
            local radius = rad / 2
            render.rect(pos - vec2_t(radius - 1, radius - 1), size + vec2_t(radius * 2 - 2, radius * 2 - 3), c:alpha(math.ceil((alpha * o) - radius * 2)), radius + 2)
        end
    end
end

---@param pos vec3_t
---@param points number
---@param radius number
---@param in_col color_t|nil
---@param out_col color_t|nil
render.circle_3d = function(pos, points, radius, in_col, out_col)
    local step = math.pi * 2 / points
    local pts = {}
    for i = 0.0, math.pi * 2.0, step do
        local p = render.world_to_screen(vec3_t(math.cos(i) * radius + pos.x, math.sin(i) * radius + pos.y, pos.z))
        if p then table.insert(pts, p) end
    end
    if in_col then render.polygon(pts, in_col) end
    if out_col then render.polyline(pts, out_col) end
end

do local skel_mesh = {{0, 1},{1, 6},{6, 5},{5, 4},{4, 3},{3, 2},{2, 7},{2, 8},{8, 10},
    {10, 12},{7, 9},{9, 11},{6, 15},{15, 16},{16, 13},{6, 17},{17, 18},{18, 14}}
---@param skel vec3_t[]
---@param color color_t
render.skeleton = function(skel, color)
    for i = 1, #skel_mesh do
        local pos1, pos2 =
        render.world_to_screen(skel[skel_mesh[i][1] + 1]), render.world_to_screen(skel[skel_mesh[i][2] + 1])
        if pos1 and pos2 then
            render.line(pos1, pos2, color)
        end
    end
end end