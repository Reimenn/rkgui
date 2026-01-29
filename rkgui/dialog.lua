local text_tool = require 'rkgui.text'

local module = {}

--- Dialog helpers for RKGUI.
---
--- This module provides reusable dialogs and small UI utilities such as:
--- - text input (`get_string`)
--- - number input with on-screen keypad (`get_number`)
--- - alert / confirm / prompt style message boxes.

--- @class InputData
--- @field text string
--- @field cursor number
--- @field scroll number
--- @field width number
--- @field term_cursor {x:number,y:number}
local InputData = {}
InputData.__index = InputData

--- Create a new `InputData` object to manage single-line text input.
---
--- @param default_text string
--- @param width number Total width of the input field (including arrow/spacing)
--- @return InputData
function InputData.new(default_text, width)
    if default_text == nil then
        default_text = ""
    end
    local inst = setmetatable({
        text = default_text,
        cursor = #default_text + 1,
        scroll = 1,
        term_cursor = { x = 1, y = 1 }
    }, InputData)
    inst:set_width(width)
    return inst
end

--- Update the total width of this input field.
---
--- This also recalculates the internal text area width.
--- @param width number
function InputData:set_width(width)
    self.width = width
    self.text_width = width - 2
end

--- Move cursor one character to the right, adjusting scroll if needed.
function InputData:cursor_to_right()
    if self.cursor <= #self.text then
        self.cursor = self.cursor + 1
    end
    if self.cursor > self.text_width then
        self.scroll = self.cursor - self.text_width + 1
    end
end

--- Move cursor one character to the left, adjusting scroll if needed.
function InputData:cursor_to_left()
    if self.cursor > 1 then
        self.cursor = self.cursor - 1
    end
    while self.cursor - 5 < self.scroll and self.scroll > 1 do
        self.scroll = self.scroll - 1
    end
end

--- Move cursor to the end of text, adjusting scroll so the end is visible.
function InputData:cursor_to_end()
    self.cursor = #self.text + 1
    if self.cursor > self.text_width then
        self.scroll = self.cursor - self.text_width + 1
    end
end

--- Move cursor to the start of text.
function InputData:cursor_to_home()
    self.cursor = 1
    self.scroll = 1
end

--- Insert a character at the cursor position and advance the cursor.
function InputData:insert(char)
    self.text = text_tool.insert(self.text, char, self.cursor + 1)
    self:cursor_to_right()
end

--- Delete the character at the current cursor position.
function InputData:delete_cursor_char()
    self.text = text_tool.removeAt(self.text, self.cursor)
end

--- Handle keyboard/char events for this input field.
---
--- It reads from `gui._last_event` and updates cursor/text accordingly.
---
--- @param gui GUI
--- @return {pressed_enter:boolean, pressed_alt:boolean} Flags for Enter/Alt actions.
function InputData:process_input_event(gui)
    local res = {
        pressed_enter = false,
        pressed_alt = false
    }
    if gui._last_event.name ~= nil then
        local event = gui._last_event.name
        local param = gui._last_event.args[1]
        if event == 'key' then
            if param == keys.left then
                self:cursor_to_left()
            elseif param == keys.right then
                self:cursor_to_right()
            elseif param == keys.home then
                self:cursor_to_home()
            elseif param == keys['end'] then
                self:cursor_to_end()
            elseif param == keys.backspace and self.cursor > 1 then
                self:cursor_to_left()
                self:delete_cursor_char()
            elseif param == keys.delete then
                self:delete_cursor_char()
            elseif param == keys.enter then
                res.pressed_enter = true
            elseif param == keys.leftAlt or param == keys.rightAlt then
                res.pressed_alt = true
            end
        elseif event == 'char' then
            self:insert(param)
        end
    end

    return res
end

--- Draw the input field (without the blinking cursor).
---
--- Allocates a 2-line area from the current layout, draws left/right arrows,
--- visible text segment and an underline using the current theme.
---
--- @param gui GUI
function InputData:draw(gui)
    local rect = gui:malloc_rect(self.width, 2)

    -- text
    gui.buffer:setCursorPos(rect.x, rect.y)
    if self.scroll > 1 then
        gui.buffer:write(string.char(17))
    else
        gui.buffer:write(" ")
    end
    gui.buffer:write(self.text:sub(self.scroll, self.scroll + self.text_width - 1))
    if self.scroll + self.text_width < #self.text + 1 then
        gui.buffer:write(string.char(16))
    else
        gui.buffer:write(" ")
    end

    -- underline
    gui.buffer:setCursorPos(rect.x + 1, rect.y + 1)
    gui.buffer:setTextColor(gui.theme:get('ghost_color'))
    gui.buffer:write(string.rep(string.char(131), self.text_width))

    -- cursor
    self.term_cursor.x = rect.x + 1 + self.cursor - self.scroll
    self.term_cursor.y = rect.y
end

--- Draw the blinking cursor of this input field.
---
--- Must be called **after** `draw()` in the same frame, otherwise the cursor
--- position will be incorrect.
--- 
--- @param gui GUI
function InputData:draw_cursor(gui)
    gui.buffer:setCursorPos(self.term_cursor.x, self.term_cursor.y)
    gui.buffer:setCursorColor(gui.theme:get('cursor_color'))
    gui.buffer:setCursorBlink(true)
end

--- Read the last char input from a GUI event, if any.
---
--- @param gui GUI
--- @return string | nil
local function check_gui_char_input(gui)
    if gui._last_event.name ~= nil then
        local type = gui._last_event.name
        local value = gui._last_event.args[1]
        if type == 'char' and #value > 0 then
            return value
        end
    end
    return nil
end

--- Read the last key code from a GUI event, if any.
---
--- @param gui GUI
--- @return number | nil
local function check_gui_key_pressed(gui)
    if gui._last_event.name ~= nil then
        local type = gui._last_event.name
        local value = gui._last_event.args[1]
        if type == 'key' and value >= 0 then
            return value
        end
    end
    return nil
end

--- Create a sub-view `GUI` instance for dialogs.
---
--- The created GUI does not register global shortcuts like Ctrl+C.
--- @return GUI
local function create_gui()
    return require('rkgui').new(true)
end

--- Show a single-line text input dialog.
---
--- Enter submits, Alt cancels. When canceled, the original `value` is returned.
---
--- @param value string
--- @param title string
--- @return string
function module.get_string(value, title)
    gui = create_gui()
    gui.theme:set('button.left_char', ' ')
    gui.theme:set('button.right_char', ' ')
    local source = value

    local term_w, term_h = gui.buffer:getSize()
    local left = math.max(2, math.floor(term_w * 0.2))
    local top = math.floor(term_h / 2)
    local data = InputData.new(value, term_w - left - left)

    local click_ok = false
    gui:start(function()
        -- update term size value
        term_w, term_h = gui.buffer:getSize()
        left = math.max(2, math.floor(term_w * 0.1))
        top = math.floor(term_h / 2)
        data:set_width(term_w - left - left)

        -- input event
        local pressed = data:process_input_event(gui)
        if pressed.pressed_enter then
            click_ok = true
            return true
        elseif pressed.pressed_alt then
            click_ok = false
            return true
        end

        local prefix = string.rep(' ', left)
        -- draw title
        gui:space(math.ceil(top - 3))
        if title then
            gui:label(prefix .. title)
        else
            gui:label(prefix .. 'Input:')
        end
        gui:space()

        -- draw input
        gui:row(2, function()
            gui:space(left - 1)
            data:draw(gui)
        end)

        -- draw buttons
        local rt = false
        gui:row(1, function()
            gui:label(string.rep(' ', left + data.width - 2 - 17))
            gui.theme:temp({
                ['button.background'] = '#background'
            }, function()
                if gui:button("Cancel", 3) then
                    click_ok = false
                    rt = true
                end
            end)

            gui:space()
            gui.theme:temp({
                ['button.background'] = '#submit_color'
            }, function()
                if gui:button("Submit", 3) then
                    click_ok = true
                    rt = true
                end
            end)
        end)

        -- draw cursor
        data:draw_cursor(gui)
        return rt
    end)

    if click_ok then
        return data.text
    else
        return source
    end
end

--- Show a blocking number input dialog with an on-screen keypad.
---
--- Supports keyboard input and/or mouse clicks on the keypad. Enter submits,
--- Cancel closes without changing the original value.
---
--- @param value number Initial value
--- @param title string Label/title shown above the value
--- @param allow_decimal boolean Whether decimal point is allowed
--- @return number The final chosen value (or original value if canceled)
function module.get_number(value, title, allow_decimal)
    gui = create_gui()
    gui.theme:set('button.left_char', ' ')
    gui.theme:set('button.right_char', ' ')

    local KEYBOARD_WIDTH = 23
    local VALUE_WIDTH = 20
    local GAP_WIDTH = 3

    local text = tostring(value)
    --- @param char string
    local pressed = function(char)
        if char:match('^%d$') then
            if text == '0' then
                if char ~= '0' then
                    text = char
                end
            elseif text == '-0' then
                if char ~= '0' then
                    text = '-' .. char
                end
            else
                text = text .. char
            end
        elseif char == '.' and allow_decimal then
            if not text:find('.', 1, true) then
                text = text .. '.'
            end
        elseif char == '-' then
            if text:sub(1, 1) == '-' then
                text = text:sub(2)
            else
                text = '-' .. text
            end
        elseif char == 'C' then
            text = '0'
        elseif char == 'R' then
            text = tostring(value)
        elseif char == string.char(17) then
            text = text:sub(1, #text - 1)
            if #text == 0 then
                text = '0'
            elseif text == '-' then
                text = '0'
            end
        end
    end

    local draw_button = function(char)
        if gui:button(" " .. char .. " ", 3) then
            pressed(char)
        end
    end

    gui:start(function()
        local to_end = false

        -- keyboard input
        local pressed_char = check_gui_char_input(gui)
        if pressed_char then
            pressed(pressed_char:upper())
        end
        local pressed_key = check_gui_key_pressed(gui)
        if pressed_key == keys.enter then
            to_end = true
            value = tonumber(text)
        elseif pressed_key == keys.backspace then
            pressed(string.char(17))
        end

        gui:row('+', function()
            local area_h = gui.last_rect.h
            local area_w = gui.last_rect.w
            -- draw left space
            if area_w > KEYBOARD_WIDTH + VALUE_WIDTH + GAP_WIDTH then
                local left = math.floor((area_w - KEYBOARD_WIDTH - VALUE_WIDTH - GAP_WIDTH) / 2)
                gui:space(left)
            end
            -- draw value col
            gui:col(VALUE_WIDTH, function()
                gui:space(math.floor((area_h - 7) / 2))
                gui:label(title)
                gui:space()
                gui:label(text, 'r')
                gui.theme:temp({
                    ['color'] = '#ghost_color'
                }, function()
                    gui:label(string.rep(string.char(131), VALUE_WIDTH))
                end)
                gui:space()
                gui:reverse_row('3', function()
                    gui.theme:temp({
                        ['button.background'] = '#submit_color',
                    }, function()
                        if gui:button('Submit', 3) then
                            value = tonumber(text)
                            to_end = true
                        end
                    end)
                    gui:space()
                    gui.theme:temp({
                        ['button.background'] = '#background'
                    }, function()
                        if gui:button('Cancel', 3) then
                            to_end = true
                        end
                    end)
                end)
            end)
            gui:space(GAP_WIDTH)
            -- draw keyboards
            gui:col(KEYBOARD_WIDTH, function()
                local top = math.floor((area_h - 15) / 2)
                if top > 0 then
                    gui:space(top)
                end

                gui:row(3, function()
                    draw_button("1")
                    gui:space()
                    draw_button("2")
                    gui:space()
                    draw_button("3")
                    gui:space()
                    draw_button(string.char(17))
                end)
                gui:space()
                gui:row(3, function()
                    draw_button("4")
                    gui:space()
                    draw_button("5")
                    gui:space()
                    draw_button("6")
                    gui:space()
                    draw_button('-')
                end)
                gui:space()
                gui:row(3, function()
                    draw_button("7")
                    gui:space()
                    draw_button("8")
                    gui:space()
                    draw_button("9")
                    gui:space()
                    gui.theme:temp({
                        ['button.background'] = '#danger_color'
                    }, function()
                        draw_button('C')
                    end)
                end)
                gui:space()
                gui:row(3, function()
                    local zero_text = '       0       '
                    if allow_decimal then
                        draw_button('.')
                        gui:space()
                        zero_text = '    0    '
                    end
                    if gui:button(zero_text, 3) then
                        pressed('0')
                    end
                    gui:space()
                    gui.theme:temp({
                        ['button.background'] = '#danger_color'
                    }, function()
                        draw_button('R')
                    end)
                end)
            end)
        end)
        return to_end
    end)

    return value
end

--- Draw dialog content (title + optional message) vertically centered.
---
--- `extend_height` is used by callers to reserve extra vertical space
--- (for example, for buttons under the message).
---
--- @param gui GUI
--- @param title string
--- @param message string|nil
--- @param extend_height number
local function draw_message(gui, title, message, extend_height)
    local _, term_h = gui.buffer:getSize()

    if message then
        local message_h = #text_tool.wrap(message)
        gui:space(math.floor((term_h - message_h - extend_height - 4) / 2))
        gui:title(title)
        gui:space()
        gui:row(message_h, function()
            gui:space()
            gui:multiline_label(message)
        end)
    else
        local message_h = #text_tool.wrap(title)
        gui:space(math.floor((term_h - message_h - extend_height) / 2))
        gui:multiline_label(title)
    end
end

--- Draw a row of buttons and return the index of the clicked one (1-based).
---
--- Each element of `buttons` can be a string or a table
--- `{ text = string, color = any }` to override the button background color.
---
--- @param gui GUI
--- @param buttons ({text:string, color:any} | string)[]
--- @return number|nil click button index
local function draw_button(gui, buttons)
    local result
    gui:reverse_row(3, function()
        for i = 1, #buttons do
            local button = buttons[i]
            if type(button) == 'table' then
                gui.theme:temp({ ['button.background'] = button.color }, function()
                    if gui:button(button.text, 3) then
                        result = i
                    end
                end)
            else
                if gui:button(button, 3) then
                    result = i
                end
            end
            gui:space()
        end
    end)
    return result
end

--- Low-level helper to show a generic dialog with custom buttons.
---
--- @param title string
--- @param message string|nil
--- @param buttons ({text:string, color:any} | string)[]
--- @return number|nil Index of the clicked button, or `nil` if none
local function show_dialog(title, message, buttons)
    local gui = create_gui()
    gui.theme:set('button.left_char', ' ')
    gui.theme:set('button.right_char', ' ')
    local click_button

    gui:start(function()
        gui:row('+', function()
            gui:space('10%')
            gui:col('80%', function()
                draw_message(gui, title, message, 4)
                gui:space()
                click_button = draw_button(gui, buttons)
            end)
        end)
        if click_button then
            return true
        end
    end)
    return click_button
end

--- Show a simple alert dialog with a single “OK” button.
---
--- @param title string
--- @param message string|nil
function module.alert(title, message)
    show_dialog(title, message, { '  OK  ' })
end

--- Show a confirm dialog with “Yes/No” buttons.
---
--- @param title string
--- @param message string|nil
--- @return boolean `true` when "Yes" is clicked, otherwise `false`
function module.confirm(title, message)
    if show_dialog(title, message, { '  Yes  ', { text = '  No  ', color = '#background' } }) == 1 then
        return true
    end
    return false
end

--- Show a 3-way prompt dialog with “Yes/No/Cancel” buttons.
---
--- @param title string
--- @param message string|nil
--- @return boolean|nil `true` for Yes, `false` for No, `nil` for Cancel/closed
function module.prompt(title, message)
    local click = show_dialog(title, message, { '  Yes  ', '  No  ', { text = ' Cancel ', color = '#background' } })
    if click == 1 then
        return true
    elseif click == 2 then
        return false
    end
    return nil
end

return module
