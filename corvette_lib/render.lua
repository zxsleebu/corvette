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
