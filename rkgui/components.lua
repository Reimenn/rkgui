local text_tools = require 'rkgui.text'
local utils = require 'rkgui.utils'
local module = {}

--- @param text string
--- @param big boolean
--- @return boolean
function module.button(gui, text, big)
    --- @module 'rkgui'
    gui = gui

    local rect
    if big then
        rect = gui.malloc_rect(#text + 2, 3)
    else
        rect = gui.malloc_rect(#text + 2, 1)
    end

    local click = gui.check_mouse_release(rect)
    local text_color

    if click then
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1,
            gui.colors.button.click.background)
        text_color = gui.colors.button.click.text
    elseif gui.check_mouse_holding(rect) then
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1,
            gui.colors.button.holding.background)
        text_color = gui.colors.button.holding.text
    else
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1,
            gui.colors.button.background)
        text_color = gui.colors.button.text
    end

    term.setTextColor(text_color)
    if big then
        term.setCursorPos(rect.x, rect.y + 1)
        term.write('|' .. text_tools.center(text, rect.w - 2) .. '|')
        term.setCursorPos(rect.x, rect.y)
        term.write('+' .. string.rep(' ', rect.w - 2) .. '+')
        term.setCursorPos(rect.x, rect.y + 2)
        term.write('+' .. string.rep(' ', rect.w - 2) .. '+')
    else
        term.setCursorPos(rect.x, rect.y)
        term.write('[' .. text_tools.center(text, rect.w - 2) .. ']')
    end
    return click
end

--- @param text string
--- @param align 'l' | 'c' | 'r' | nil
function module.label(gui, text, align)
    --- @module 'rkgui'
    gui = gui
    local rect = gui.malloc_rect(#text, 1)
    if align == 'r' then
        text = text_tools.right(text, rect.w)
    elseif align == 'c' then
        text = text_tools.center(text, rect.w)
    end

    term.setTextColor(gui.colors.label.text)
    term.setBackgroundColor(gui.colors.label.background)
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

    local box_color
    local box_char


    if gui.check_mouse_holding(click_rect) then
        box_color = gui.colors.checkbox.holding_box
        box_char = '='
    elseif checked then
        box_color = gui.colors.checkbox.checked_box
        box_char = ' '
    else
        box_color = gui.colors.checkbox.unchecked_box
        box_char = string.char(127)
    end

    term.setCursorPos(rect.x, rect.y)
    if checked then
        term.setBackgroundColor(box_color)
        term.setTextColor(box_color)
        term.write(' ')
    else
        term.setBackgroundColor(gui.colors.checkbox.background)
        term.setTextColor(box_color)
        term.write(box_char)
    end
    term.setBackgroundColor(gui.colors.checkbox.background)
    term.setTextColor(gui.colors.checkbox.text)
    term.write(' ' .. text)
    return checked
end

local progress_bar_stage_table = {
    string.char(144),
    string.char(148),
    string.char(149),
    string.char(151),
    string.char(159),
    ' ',
}

--- @param percent number
--- @param show_percent boolean
function module.progress_bar(gui, percent, show_percent)
    --- @module 'rkgui'
    gui = gui
    local rect = gui.malloc_rect(10, 1)

    term.setTextColor(gui.colors.progress_bar.text)
    term.setBackgroundColor(gui.colors.progress_bar.background)

    -- percent title
    if show_percent then
        local title = text_tools.right(string.format('%d', percent * 100) .. '% ', 5)
        term.setCursorPos(rect.x, rect.y)
        term.write(title)
        rect.x = rect.x + 5
        rect.w = rect.w - 5
    end

    -- background
    term.setBackgroundColor(gui.colors.progress_bar.bar_background)
    term.setCursorPos(rect.x, rect.y)
    term.write(string.rep(' ', rect.w))

    -- progress
    if percent > 0 then
        term.setCursorPos(rect.x, rect.y)
        term.setBackgroundColor(gui.colors.progress_bar.bar)
        local width = (rect.w) * percent
        local width_floor = math.floor(width)
        term.write(string.rep(' ', width_floor))

        -- remain
        local remain = width - width_floor
        if remain > 0 then
            local stage = math.floor(remain * 6) + 1
            term.setTextColor(gui.colors.progress_bar.bar)
            term.setBackgroundColor(gui.colors.progress_bar.bar_background)
            if stage == 6 then term.setBackgroundColor(gui.colors.progress_bar.bar) end
            term.write(progress_bar_stage_table[stage])
        end
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
    term.setCursorPos(rect.x, rect.y)
    term.setTextColor(gui.colors.slider.text)
    term.setBackgroundColor(gui.colors.slider.background)


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
    term.setTextColor(gui.colors.slider.slider)
    term.write('<' .. string.rep(string.char(140), rect.w - 2) .. '>')

    -- value indicator
    local percent = (value - min) / (max - min)
    local indicator_left = (rect.w - 3) * percent
    term.setCursorPos(rect.x + indicator_left + 1, rect.y)
    term.setBackgroundColor(gui.colors.slider.indicator)
    term.write(' ')

    -- input
    local slider_rect = utils.Rect.new()
    slider_rect.x = rect.x + 1
    slider_rect.y = rect.y
    slider_rect.w = rect.w - 2
    slider_rect.h = rect.h
    if gui.check_mouse_holding(slider_rect) then
        percent = (gui.hover.x - slider_rect.x) / (slider_rect.w - 1)
        value = (max - min) * percent + min
        if integer then
            value = math.ceil(value)
        end
    elseif gui.last_event.name == 'mouse_scroll' and
        slider_rect:point_in(gui.last_event.args[2], gui.last_event.args[3])
    then
        value = value - gui.last_event.args[1]
        if value > max then
            value = max
        elseif value < min then
            value = min
        end
    end

    return value
end

--- @param selected integer
--- @param tabs {[integer]:string}
--- @return integer
function module.tabs(gui, selected, tabs)
    --- @module 'rkgui'
    gui = gui

    -- width check & malloc rect
    local need_width = 0
    for i = 1, #tabs do need_width = need_width + #(tabs[i]) + 2 end
    local rect = gui.malloc_rect(need_width, 1)

    -- input check
    local check_x = rect.x
    for i = 1, #tabs do
        local click_rect           = utils.Rect.new()
        click_rect.x, click_rect.y = check_x, rect.y
        click_rect.w, click_rect.h = #(tabs[i]) + 2, 1
        if gui.check_mouse_release(click_rect) then
            selected = i
        end
        check_x = check_x + click_rect.w
    end

    -- draw
    term.setCursorPos(rect.x, rect.y)
    for i = 1, #tabs do
        local text = ' ' .. tabs[i] .. ' '
        if selected == i then
            term.setBackgroundColor(gui.colors.tabs.selected.background)
            term.setTextColor(gui.colors.tabs.selected.text)
        else
            term.setBackgroundColor(gui.colors.tabs.background)
            term.setTextColor(gui.colors.tabs.text)
        end
        term.write(text)
    end

    return selected
end

return module
