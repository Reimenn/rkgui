local text_tools = require 'rkgui.text'
local utils = require 'rkgui.utils'

--- RKGUI built-in components.
---
--- This module contains the core widget implementations used by `rkgui/init.lua`.
--- Most functions follow an immediate-mode pattern: call the function to draw the widget,
--- and it returns the new state (or whether it was clicked).
local module = {}

--- Draw a button.
---
--- The width is automatically calculated from the text plus theme decorations.
--- Returns `true` only on click release (mouse_up/monitor_touch) inside the button rect.
--- @param gui GUI
--- @param text string
--- @param height number
--- @return boolean
function module.button(gui, text, height)
    text = tostring(text)
    local decoration_char_length = #gui.theme:get('button.left_char') + #gui.theme:get('button.right_char')
    local rect = gui:malloc_rect(#text + decoration_char_length, height)

    local click = gui:check_click(rect)
    if click then
        gui.theme:apply('button.click')
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1)
    elseif gui:check_mouse_holding(rect) then
        gui.theme:apply('button.holding')
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1)
    else
        gui.theme:apply('button')
        paintutils.drawFilledBox(rect.x, rect.y, rect.x + rect.w - 1, rect.y + rect.h - 1)
    end

    local draw_text = text_tools.center(text, rect.w - decoration_char_length)
    term.setCursorPos(rect.x, rect.y + math.floor(rect.h / 2))
    term.write(gui.theme:get('button.left_char'))
    term.write(draw_text)
    term.write(gui.theme:get('button.right_char'))
    return click
end

--- Draw a single-line label.
---
--- The label takes exactly the width of `text` (no auto-wrapping). Use `GUI:multiline_label`
--- for wrapping.
--- @param gui GUI
--- @param text string
--- @param align 'l' | 'c' | 'r' | nil
function module.label(gui, text, align)
    text = tostring(text)
    local rect = gui:malloc_rect(#text, 1)
    if align == 'r' then
        text = text_tools.right(text, rect.w)
    elseif align == 'c' then
        text = text_tools.center(text, rect.w)
    else
        text = text_tools.left(text, rect.w)
    end

    term.setCursorPos(rect.x, rect.y)
    gui.theme:draw_string('label', text)
end

--- Draw a title (3 lines tall): one line of text and a separator line below.
--- @param gui GUI
--- @param text string
--- @param align 'l' | 'c' | 'r' | nil
function module.title(gui, text, align)
    text = tostring(text)
    local rect = gui:malloc_rect(#text, 3)
    if align == nil then
        align = 'l'
    end

    if align == 'r' then
        text = text_tools.right(text .. ' ', rect.w)
    elseif align == 'c' then
        text = text_tools.center(text, rect.w)
    else
        text = text_tools.left(' ' .. text, rect.w)
    end

    term.setCursorPos(rect.x, rect.y + 1)
    gui.theme:draw_string('title', text)

    term.setCursorPos(rect.x, rect.y + 2)
    term.setTextColor(gui.theme:get('title.line'))
    term.setBackgroundColor(gui.theme:get('background'))
    term.write(string.rep(string.char(131), rect.w))
end

--- Draw a checkbox and return the updated checked state.
---
--- Click anywhere on the checkbox+text area to toggle.
--- @param gui GUI
--- @param text string
--- @param checked boolean
--- @return boolean
function module.checkbox(gui, text, checked)
    text = tostring(text)
    local rect = gui:malloc_rect(#text + 2, 1)
    --- @type Rect
    local click_rect = utils.shallow_copy(rect)
    click_rect.w = #text + 2
    if gui:check_click(click_rect) then
        checked = not checked
    end

    term.setCursorPos(rect.x, rect.y)
    if checked then
        gui.theme:draw_char('checkbox.checked')
    else
        gui.theme:draw_char('checkbox.unchecked')
    end
    gui.theme:draw_string('checkbox', ' ' .. text)
    return checked
end

--- Draw a toggle switch and return the updated checked state.
---
--- Click to toggle. Hover shows a "pressed/holding" visual state.
--- @param gui GUI
--- @param text string
--- @param checked boolean
--- @return boolean
function module.toggle(gui, text, checked)
    text = tostring(text)
    local rect = gui:malloc_rect(#text + 4, 1)

    local click = gui:check_click(rect)
    if click then
        checked = not checked
    end

    term.setCursorPos(rect.x, rect.y)
    if gui:check_mouse_holding(rect) then
        gui.theme:draw_char('toggle.track.on')
        gui.theme:draw_char('toggle.thumb')
        gui.theme:draw_char('toggle.track.off')
    elseif checked then
        gui.theme:draw_char('toggle.track.on', 2)
        gui.theme:draw_char('toggle.thumb')
    else
        gui.theme:draw_char('toggle.thumb')
        gui.theme:draw_char('toggle.track.off', 2)
    end

    gui.theme:draw_string('toggle', ' ' .. text)

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

--- Draw a progress bar.
---
--- @param gui GUI
--- @param percent number Progress in range [0, 1]. Values outside this range are still drawn,
--- but callers should clamp if they want strict behavior.
--- @param show_percent boolean If true, show a right-aligned percentage label prefix.
function module.progress_bar(gui, percent, show_percent)
    local rect = gui:malloc_rect(10, 1)

    -- Percent label prefix
    if show_percent then
        local title = text_tools.right(string.format('%d', percent * 100) .. '% ', 5)
        term.setCursorPos(rect.x, rect.y)
        gui.theme:draw_string('progress', title)
        rect.x = rect.x + 5
        rect.w = rect.w - 5
    end

    -- Background

    term.setCursorPos(rect.x, rect.y)
    gui.theme:draw_string('progress.bar', string.rep(' ', rect.w))

    -- Filled part
    if percent > 0 then
        term.setCursorPos(rect.x, rect.y)
        term.setBackgroundColor(gui.theme:get('progress.bar.color'))
        local width = (rect.w) * percent
        local width_floor = math.floor(width)
        term.write(string.rep(' ', width_floor))

        -- Remaining fractional part (use 1/6-block characters)
        local remain = width - width_floor
        if remain > 0 then
            local stage = math.floor(remain * 6) + 1
            term.setBackgroundColor(gui.theme:get('progress.bar.background'))
            term.setTextColor(gui.theme:get('progress.bar.color'))
            if stage == 6 then
                term.setBackgroundColor(gui.theme:get('progress.bar.color'))
            end
            term.write(progress_bar_stage_table[stage])
        end
    end
end

--- Draw a horizontal slider and return the updated value.
---
--- Supports mouse drag, click-to-jump, and mouse wheel when the cursor is over the slider.
---
--- @param gui GUI
--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @param show_number boolean
--- @return number
function module.slider(gui, value, min, max, integer, show_number)
    local rect = gui:malloc_rect(20, 1)
    term.setCursorPos(rect.x, rect.y)

    -- Numeric prefix (optional)
    if show_number then
        local prefix = ''
        if integer then
            local max_number_len = math.max(#(max .. ''), 4)
            prefix = text_tools.right(string.format('%d', value), max_number_len) .. ' '
        else
            local max_number_len = math.max(#(max .. ''), 4) + 2
            prefix = text_tools.right(string.format('%.1f', value), max_number_len) .. ' '
        end
        gui.theme:draw_string('slider', prefix)
        rect.x = rect.x + #prefix
        rect.w = rect.w - #prefix
    end

    -- Slider track
    gui.theme:draw_string('slider.endpoint', '[')
    gui.theme:draw_char('slider.slider', rect.w - 2)
    gui.theme:draw_string('slider.endpoint', ']')


    -- Value indicator (thumb)
    local percent = (value - min) / (max - min)
    local indicator_left = (rect.w - 3) * percent
    term.setCursorPos(rect.x + indicator_left + 1, rect.y)
    gui.theme:draw_char('slider.indicator')

    -- Input handling area (excluding endpoints)
    local slider_rect = utils.Rect.new()
    slider_rect.x = rect.x + 1
    slider_rect.y = rect.y
    slider_rect.w = rect.w - 2
    slider_rect.h = rect.h

    if gui:check_mouse_holding(slider_rect) then
        percent = (gui._hover.x - slider_rect.x) / (slider_rect.w - 1)
        value = (max - min) * percent + min
    elseif gui:check_click(slider_rect) then
        percent = (gui._last_event.args[2] - slider_rect.x) / (slider_rect.w - 1)
        value = (max - min) * percent + min
    elseif gui._last_event.name == 'mouse_scroll' and
            slider_rect:point_in(gui._last_event.args[2], gui._last_event.args[3])
    then
        value = value - gui._last_event.args[1]
    end

    -- Clamp to range
    if value > max then
        value = max
    elseif value < min then
        value = min
    end

    if integer then
        value = math.ceil(value)
    end

    return value
end

--- Draw a vertical slider and return the updated value.
---
--- Supports mouse drag, click-to-jump, and mouse wheel when the cursor is over the slider.
--- @param gui GUI
--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @return number
function module.vertical_slider(gui, value, min, max, integer)
    local rect = gui:malloc_rect(1, '+')
    term.setCursorPos(rect.x, rect.y)

    -- Slider track
    for i = rect.y, rect.y + rect.h - 1 do
        term.setCursorPos(rect.x, i)
        gui.theme:apply('slider.slider')
        term.write('|')
    end

    -- Value indicator (thumb)
    local percent = (value - min) / (max - min)
    local indicator_top = math.floor((rect.h - 1) * percent)
    term.setCursorPos(rect.x, rect.y + indicator_top)
    gui.theme:draw_string('slider.indicator', string.char(9))
    
    -- Input handling
    if gui:check_mouse_holding(rect) then
        percent = (gui._hover.y - rect.y) / (rect.h - 1)
        value = (max - min) * percent + min
    elseif gui:check_click(rect) then
        percent = (gui._last_event.args[3] - rect.y) / (rect.h - 1)
        value = (max - min) * percent + min
    elseif gui._last_event.name == 'mouse_scroll' and rect:point_in(gui._last_event.args[2], gui._last_event.args[3]) then
        value = value + gui._last_event.args[1]
    end

    -- Clamp to range
    if value > max then
        value = max
    elseif value < min then
        value = min
    end

    if integer then
        value = math.ceil(value)
    end

    return value
end

--- Draw a tab bar and return the selected tab index (1-based).
---
--- @param gui GUI
--- @param selected number
--- @param tabs string[]
--- @param full boolean|nil
--- @return number
function module.tabs(gui, selected, tabs, full)
    for i = 1, #tabs do
        tabs[i] = tostring(tabs[i])
    end

    local need_width = 0
    local widths = {}
    --- @type Rect
    local rect

    -- Compute widths and allocate rect
    for i = 1, #tabs do
        local w = #(tabs[i]) + 2
        need_width = need_width + w
        table.insert(widths, w)
    end

    if full then
        rect = gui:malloc_rect('+', 1)
        while need_width < rect.w do
            local min_v = rect.w
            local min_i = 1
            for i = 1, #widths do
                if widths[i] < min_v then
                    min_v = widths[i]
                    min_i = i
                end
            end
            need_width = need_width + 1
            widths[min_i] = widths[min_i] + 1
        end
    else
        rect = gui:malloc_rect(need_width, 1)
    end

    -- Input handling
    local click_rect = utils.Rect.new()
    click_rect.x, click_rect.y = rect.x, rect.y
    for i = 1, #tabs do
        click_rect.w, click_rect.h = widths[i], 1
        if gui:check_click(click_rect) then
            selected = i
        end
        click_rect.x = click_rect.x + click_rect.w
    end

    -- Draw
    term.setCursorPos(rect.x, rect.y)
    for i = 1, #tabs do
        local left_space = 1
        local right_space = widths[i] - #(tabs[i]) - 1
        local text = string.rep(' ', left_space) .. tabs[i] .. string.rep(' ', right_space)
        if selected == i then
            gui.theme:draw_string('tabs.selected', text)
        else
            gui.theme:draw_string('tabs', text)
        end
    end

    return selected
end

return module
