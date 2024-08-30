local default_style_ini = [[
bg = black
fg = white

[button]
bg = gray
left = '['
right = ']'

[button.holding]
bg = lightGray

[button.active]
bg = black

[checkbox]
checked = green
unchecked = red
holding = orange

[progress_bar]
bar_bg = gray
bar = white

[slider]
slider = gray
indicator = white

[tabs]
bg = gray
fg = black

[tabs.selected]
bg = lightGray
]]

local text_tools = require 'rkgui.text'
local utils = require 'rkgui.utils'
local theme = {}

--- @param text string
--- @return {[string]:any}
function theme.parse_style_ini(text)
    local lines = text_tools.split(text, '\n')
    local res = {}
    local key_base = ""

    for line_number, line in pairs(lines) do
        line = text_tools.trim(line)
        local first_char = line:sub(1, 1)

        if first_char == ';' then goto continue end

        if first_char == '[' and line:sub(#line) == ']' then
            key_base = text_tools.trim(line:sub(2, #line - 1))
            goto continue
        end

        local split_pos = line:find('=')
        if split_pos == nil then goto continue end

        local key = text_tools.trim(line:sub(1, split_pos - 1))
        local value = text_tools.trim(line:sub(split_pos + 1))
        if #key == 0 or #value == 0 then goto continue end

        if #key_base > 0 then
            res[key_base .. '.' .. key] = value
        else
            res[key] = value
        end

        ::continue::
    end

    return res
end

--- @type {[string]:any}[]
theme.list = { theme.parse_style_ini(default_style_ini) }

--- @param key string
--- @return any|nil
function theme.get(key)
    for i = 1, #theme.list do
        local val = theme.list[i][key]
        if val then
            return val
        end
    end
    for i = #key, 1, -1 do
        if key:sub(i, i) == '.' then
            local parent_key = key:sub(0, i - 1)
            return theme.get(parent_key)
        end
    end
    return nil
end

function theme.add(style)
    table.insert(theme.list, style)
end

function theme.remove()
    table.remove(theme.list, 1)
end

return theme
