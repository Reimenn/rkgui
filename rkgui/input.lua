local text_tool = require 'rkgui.text'

local model = {}

--- @class InputData
--- @field text string
--- @field cursor number
--- @field scroll number
--- @field width number
--- @field term_cursor {x:number,y:number}
local InputData = {}
InputData.__index = InputData

--- @param default_text string
--- @param width number
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

--- @param width number
function InputData:set_width(width)
    self.width = width
    self.text_width = width - 2
end

function InputData:cursor_to_right()
    if self.cursor <= #self.text then
        self.cursor = self.cursor + 1
    end
    if self.cursor > self.text_width then
        self.scroll = self.cursor - self.text_width + 1
    end
end

function InputData:cursor_to_left()
    if self.cursor > 1 then
        self.cursor = self.cursor - 1
    end
    while self.cursor - 5 < self.scroll and self.scroll > 1 do
        self.scroll = self.scroll - 1
    end
end

function InputData:cursor_to_end()
    self.cursor = #self.text + 1
    if self.cursor > self.text_width then
        self.scroll = self.cursor - self.text_width + 1
    end
end

function InputData:cursor_to_home()
    self.cursor = 1
    self.scroll = 1
end

function InputData:insert(char)
    self.text = text_tool.insert(self.text, char, self.cursor + 1)
    self:cursor_to_right()
end

function InputData:delete_cursor_char()
    self.text = text_tool.removeAt(self.text, self.cursor)
end

--- @return {pressed_enter:boolean, pressed_alt:boolean}
function InputData:process_input_event(gui)
    --- @module 'rkgui'
    gui = gui
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
            elseif param == keys.backspace and data.cursor > 1 then
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

function InputData:draw(gui)
    --- @module 'rkgui'
    gui = gui
    local rect = gui:malloc_rect(self.width, 2)

    -- text
    term.setCursorPos(rect.x, rect.y)
    if self.scroll > 1 then
        term.write(string.char(17))
    else
        term.write(" ")
    end
    term.write(self.text:sub(self.scroll, self.scroll + self.text_width - 1))
    if self.scroll + self.text_width < #self.text + 1 then
        term.write(string.char(16))
    else
        term.write(" ")
    end

    -- underline
    term.setCursorPos(rect.x + 1, rect.y + 1)
    term.write(string.rep(string.char(131), self.text_width))

    -- cursor
    self.term_cursor.x = rect.x + 1 + self.cursor - self.scroll
    self.term_cursor.y = rect.y
end

--- It needs to be used after the draw method is executed; otherwise, the cursor position will be incorrect.
function InputData:draw_cursor()
    term.setCursorPos(self.term_cursor.x, self.term_cursor.y)
    term.setTextColor(colors.red)
    term.setCursorBlink(true)
end

--- @param gui GUI
--- @return string | nil
function check_gui_char_input(gui)
    if gui._last_event.name ~= nil then
        local type = gui._last_event.name
        local value = gui._last_event.args[1]
        if type == 'char' and #value > 0 then
            return value
        end
    end
    return nil
end

--- @param gui GUI
--- @return number | nil
function check_gui_key_pressed(gui)
    if gui._last_event.name ~= nil then
        local type = gui._last_event.name
        local value = gui._last_event.args[1]
        if type == 'key' and value >= 0 then
            return value
        end
    end
    return nil
end

--- @param value string
--- @param title string
--- @return string
function model.get_string(value, title)
    --- @module 'rkgui'
    gui = require('rkgui').new()
    gui:remove_shortcut('exit')
    local source = value

    local term_w, term_h = term.getSize()
    local left = math.max(2, math.floor(term_w * 0.2))
    local top = math.floor(term_h / 2)
    local data = InputData.new(value, term_w - left - left)

    local click_ok = false
    gui:start(function()
        -- update term size value
        term_w, term_h = term.getSize()
        left = math.max(2, math.floor(term_w * 0.2))
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
        gui:space(math.ceil((term_h / 2) - 4))
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
            gui:label(string.rep(' ', left - 1 + data.width - 2 - 17))
            if gui:button("Cancel") then
                click_ok = false
                rt = true
            end
            gui:space()
            if gui:button("Submit") then
                click_ok = true
                rt = true
            end
        end)

        -- draw cursor
        data:draw_cursor()

        return rt
    end)

    term.setCursorBlink(false)
    if click_ok then
        return data.text
    else
        return source
    end
end

function model.get_number(value, title, allow_decimal)
    gui = require('rkgui').new()
    gui:remove_shortcut('exit')
    gui.theme:set('button.left_char', ' ')
    gui.theme:set('button.right_char', ' ')

    local KEYBOARD_WIDTH = 23
    local VALUE_WIDTH = 17
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
                gui:label(string.rep(string.char(131), VALUE_WIDTH))
                gui:space()
                gui:reverse_row('3', function()
                    local bg = gui.theme:get('button.background')
                    if gui:button('Submit', 3) then
                        value = tonumber(text)
                        to_end = true
                    end
                    gui:space()
                    gui.theme:set('button.background', '#background')
                    if gui:button('Cancel', 3) then
                        to_end = true
                    end
                    gui.theme:set('button.background', bg)
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
                    local bg = gui.theme:get('button.background')
                    gui.theme:set('button.background', '#keyboard.danger_color')
                    draw_button('C')
                    gui.theme:set('button.background', bg)
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
                    local bg = gui.theme:get('button.background')
                    gui.theme:set('button.background', '#keyboard.danger_color')
                    draw_button('R')
                    gui.theme:set('button.background', bg)
                end)
            end)
        end)
        return to_end
    end)

    return value
end

return model
