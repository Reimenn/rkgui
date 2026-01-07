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
        cursor = 1,
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

--- @param value string
--- @param title string
--- @return string
function model.get(value, title)
    --- @module 'rkgui'
    gui = require('rkgui').new()
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

return model
