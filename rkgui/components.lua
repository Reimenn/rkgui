local text_tools = require 'rkgui.text'
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
    term.setCursorPos(rect.x,rect.y)
    term.write(string.rep(string.char(127), rect.w))
    -- paintutils.drawBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.gray)
    if percent > 0 then
        local width = math.floor(rect.w * percent)
        paintutils.drawBox(rect.x, rect.y, rect.x + width, rect.y, colors.white)
    end
end

return module
