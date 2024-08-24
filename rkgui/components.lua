local text_tools = require 'rkgui.text'
local utils = require 'rkgui.utils'
local utils = require 'rkgui.utils'
local module = {}

--- @param text string
--- @return boolean
function module.button(gui, text)
    --- @module 'rkgui'
    gui = gui

    local rect = gui.malloc_rect(#text + 2, 1)
    local click = gui.check_mouse_release(rect)

    if gui.check_mouse_hover(rect) then
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.lightGray)
    else
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.gray)
    end

    term.setCursorPos(rect.x, rect.y)
    term.write('[' .. text_tools.center(text, rect.w - 2) .. ']')
    return click
end

--- @param text string
--- @return boolean
function module.button_big(gui, text)
    --- @module 'rkgui'
    gui = gui

    local rect = gui.malloc_rect(#text + 2, 3)
    local click = gui.check_mouse_release(rect)

    if gui.check_mouse_hover(rect) then
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1, colors.lightGray)
    else
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1, colors.gray)
    end

    term.setCursorPos(rect.x, rect.y + 1)
    term.write('|' .. text_tools.center(text, rect.w - 2) .. '|')
    term.setCursorPos(rect.x, rect.y)
    term.write('+' .. string.rep(' ', rect.w - 2) .. '+')
    term.setCursorPos(rect.x, rect.y + 2)
    term.write('+' .. string.rep(' ', rect.w - 2) .. '+')

    return click
end

--- @param text string
--- @param align 'l' | 'c' | 'r' | nil
function module.label(gui, text, align)
    local rect = gui.malloc_rect(#text, 1)
    if align == 'r' then
        text = text_tools.right(text, rect.w)
    elseif align == 'c' then
        text = text_tools.center(text, rect.w)
    end

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(rect.x, rect.y)
    term.write(text)
end

--- @param text string
--- @param checked boolean
--- @return boolean
function module.checkbox(gui, text, checked)
    --- @module 'rkgui'
    gui = gui
    local rect = gui.malloc_rect(#text + 2, 1)

    --- @type Rect
    local click_rect = utils.shallow_copy(rect)
    click_rect.w = #text + 2
    if gui.check_mouse_release(click_rect) then
        checked = not checked
    end

    term.setCursorPos(rect.x, rect.y)

    if gui.check_mouse_hover(click_rect) then
        term.blit('=', '1', 'l')
    elseif checked then
        term.blit(' ', 'e', '5')
    else
        term.blit(string.char(127), 'e', 'l')
    end

    term.blit(' ', '0', 'f')
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.write(text)
    return checked
end

--- @param percent number
--- @param show_percent boolean
function module.percent(gui, percent, show_percent)
    --- @module 'rkgui'
    gui = gui
    local rect = gui.malloc_rect(10, 1)

    if show_percent then
        local title = text_tools.right(string.format('%d', percent * 100) .. '% ', 5)
        term.setCursorPos(rect.x, rect.y)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.write(title)
        rect.x = rect.x + 5
        rect.w = rect.w - 5
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    term.setCursorPos(rect.x, rect.y)
    term.write(string.rep(string.char(127), rect.w))
    -- paintutils.drawBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.gray)
    if percent > 0 then
        local width = math.floor(rect.w * percent)
        paintutils.drawBox(rect.x, rect.y, rect.x + width, rect.y, colors.white)
    end
end

--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @param show_number boolean
--- @return number
function module.slider(gui, value, min, max, integer, show_number)
    --- @module 'rkgui'
    gui = gui
    local rect = gui.malloc_rect(20, 1)

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(rect.x, rect.y)

    -- number prefix
    if show_number then
        local prefix = ''
        if integer then
            local max_number_len = math.max(#(max .. ''), 4)
            prefix = text_tools.right(string.format('%d', value), max_number_len) .. ' '
        else
            local max_number_len = math.max(#(max .. ''), 4) + 2
            prefix = text_tools.right(string.format('%.1f', value), max_number_len) .. ' '
        end
        term.write(prefix)
        rect.x = rect.x + #prefix
        rect.w = rect.w - #prefix
    end

    -- slider body
    term.setTextColor(colors.gray)
    term.write('<' .. string.rep(string.char(140), rect.w - 2) .. '>')

    -- value indicator
    local percent = (value - min) / (max - min)
    local indicator_left = (rect.w - 3) * percent
    term.setCursorPos(rect.x + indicator_left + 1, rect.y)
    term.blit(' ', '0', '0')

    -- input
    local slider_rect = utils.Rect.new()
    slider_rect.x = rect.x + 1
    slider_rect.y = rect.y
    slider_rect.w = rect.w - 2
    slider_rect.h = rect.h
    if gui.check_mouse_hover(slider_rect) then
        percent = (gui.hover.x - slider_rect.x) / (slider_rect.w - 1)
        value = (max - min) * percent + min
        if integer then
            value = math.ceil(value)
        end
    end

    return value
end

return module
