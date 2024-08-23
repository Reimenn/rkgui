local text_tools = require 'rkgui.text'
local module = {}

--- @param text string
--- @param rect Rect
--- @return boolean
function module.button(gui, rect, text)
    --- @module 'rkgui'
    gui = gui
    local click = false

    if gui.last_event.name == 'mouse_up' then
        click = rect:point_in(gui.last_event.args[2], gui.last_event.args[3])
    end

    if gui.hover and rect:point_in(gui.hover.x, gui.hover.y) then
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.lightGray)
    else
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y, colors.gray)
    end

    term.setCursorPos(rect.x, rect.y)
    term.write(text_tools.center(text, rect.w))
    return click
end

--- @param text string
--- @param rect Rect
--- @param align 'l' | 'c' | 'r'
function module.label(gui, rect, text, align)
    if align == 'r' then
        text = text_tools.right(text, rect.w)
    elseif align == 'c' then
        text = text_tools.center(text, rect.w)
    end
    term.setBackgroundColor(colors.black)
    term.setCursorPos(rect.x, rect.y)
    term.write(text)
end

--- @param text string
--- @param rect Rect
--- @param checked boolean
--- @return boolean
function module.checkbox(gui, rect, text, checked)
    if gui.last_event.name == 'mouse_up' then
        if rect:point_in(gui.last_event.args[2], gui.last_event.args[3]) then
            checked = not checked
        end
    end

    term.setCursorPos(rect.x, rect.y)

    if checked then
        term.blit(' ', 'e', '5')
    else
        term.blit(string.char(127), 'e', 'l')
    end
    
    term.blit(' ', '0', 'f')
    term.write(text)
    return checked
end

return module
