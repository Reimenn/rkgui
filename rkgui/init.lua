local utils = require 'rkgui.utils'
local components = require 'rkgui.components'
local text_tools = require 'rkgui.text'

---@class GUI
---@field theme Theme
---@field last_rect Rect
---@field show_logs boolean
---@field _layouts Stack<Layout>
---@field _hover {x:number,y:number}
---@field _last_event {name:string,args:any[]}
---@field _debug_buffer {msg:string,level:number}[]
---@field _keyboard_shortcuts {name:string,keys:string[],action:fun()}[]
---@field _holding_keys number[]
---@field _end_loop boolean
local GUI = {}
GUI.__index = GUI

--- @param is_sub_view boolean|nil
--- @return GUI
function GUI.new(is_sub_view)
    --- @type GUI
    local inst = setmetatable({
        theme = require 'rkgui.theme.default'(),
        last_rect = nil,
        show_logs = false,
        _layouts = utils.Stack.new(),
        _hover = nil,
        _last_event = {},
        _debug_buffer = {},
        _keyboard_shortcuts = {},
        _holding_keys = {},
        _end_loop = false
    }, GUI)
    if not is_sub_view then
        inst:add_shortcut('exit', { keys.leftCtrl, keys.c }, function()
            inst:stop()
        end)
        inst:add_shortcut('logs', { keys.leftAlt, keys.l }, function()
            inst.show_logs = not inst.show_logs
        end)
    end

    return inst
end

--- Check if mouse hover on rect
--- @param rect Rect
--- @return boolean
function GUI:check_mouse_holding(rect)
    return self._hover and rect:point_in(self._hover.x, self._hover.y)
end

--- Check if mouse release on rect
--- @param rect Rect
--- @return boolean
function GUI:check_click(rect)
    return (self._last_event.name == 'mouse_up' and rect:point_in(self._last_event.args[2], self._last_event.args[3]))
            or (self._last_event.name == 'monitor_touch' and rect:point_in(self._last_event.args[2], self._last_event.args[3]))
end

--- @param text string
--- @param height number|nil
--- @return boolean
function GUI:button(text, height)
    if height == nil then
        height = 1
    end
    return components.button(self, text, height)
end

--- @param text string
--- @param align nil | 'l' | 'r' | 'c'
function GUI:label(text, align)
    components.label(self, text, align)
end

--- @param text string
--- @param align nil | 'l' | 'r' | 'c'
function GUI:title(text, align)
    components.title(self, text, align)
end

--- @param text string
function GUI:multiline_label(text)
    local total_w = self._layouts:peek().rect.w
    local line = text_tools.wrap(text, total_w)
    for i = 1, #line do
        self:label(line[i])
    end
end

--- @param text string
--- @param checked boolean
--- @return boolean
function GUI:checkbox(text, checked)
    return components.checkbox(self, text, checked)
end

--- @param text string
--- @param checked boolean
--- @return boolean
function GUI:toggle(text, checked)
    return components.toggle(self, text, checked)
end

--- @param percent number [0,1]
--- @param show_percent boolean
function GUI:progress_bar(percent, show_percent)
    components.progress_bar(self, percent, show_percent)
end

--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @param show_number boolean
--- @return number
function GUI:slider(value, min, max, integer, show_number)
    return components.slider(self, value, min, max, integer, show_number)
end

--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @return number
function GUI:vertical_slider(value, min, max, integer)
    return components.vertical_slider(self, value, min, max, integer)
end

--- @param selected number
--- @param tabs string[]
--- @param full boolean|nil
--- @return number
function GUI:tabs(selected, tabs, full)
    return components.tabs(self, selected, tabs, full)
end

--- @param space number | nil
--- @param char string | nil
function GUI:space(space, char)
    if space == nil then
        space = 1
    end

    -- @type Layout
    local l = self._layouts:peek()
    local rect
    if l.dir == 'lr' or l.dir == 'rl' then
        rect = self:malloc_rect(space, '+')
    else
        rect = self:malloc_rect('+', space)
    end

    if char then
        for i = rect.y, rect.y + rect.h - 1 do
            term.setCursorPos(rect.x, i)
            term.write(string.rep(char, rect.w))
        end
    end
end

--- @return Rect
function GUI:get_current_layout_rect()
    return self._layouts:peek().rect
end

--- @param width number | string
---@param height number | string
---@param dir 'lr'|'rl'|'tb'|'bt'
---@param view fun():(boolean|nil)
function GUI:_draw_in_layout(width, height, dir, view)
    self._layouts:push(utils.Layout.new(
            self:malloc_rect(width, height),
            dir
    ))
    view()
    self._layouts:pop()
end

--- Use `height` to specify the height of this row,
--- you can use numbers 1, 2, 3... to indicate the specific height,
--- or use a string such as "50%" to indicate the percentage height,
--- or use "+" to fill the remaining height.
--- @param height number | string
--- @param view fun():(boolean|nil) Draw the UI in the function
function GUI:row(height, view)
    self:_draw_in_layout('+', height, 'lr', view)
end

--- Like `row()` but reverse
--- @param height number | string
--- @param view fun():(boolean|nil) Draw the UI in the function
function GUI:reverse_row(height, view)
    self:_draw_in_layout('+', height, 'rl', view)
end

--- Use `width` to specify the width of this column,
--- you can use numbers 1, 2, 3... to indicate the specific width,
--- or use a string such as "50%" to indicate a percentage width,
--- or use "+" to fill the remaining width.
--- @param width number | string
--- @param view fun():(boolean|nil) Draw the UI in the function
function GUI:col(width, view)
    self:_draw_in_layout(width, '+', 'tb', view)
end

--- Like `col()` but reverse
--- @param width number | string
--- @param view fun():(boolean|nil) Draw the UI in the function
function GUI:reverse_col(width, view)
    self:_draw_in_layout(width, '+', 'bt', view)
end

--- @param width number|string|nil
--- @param height number|string|nil
--- @return Rect
function GUI:malloc_rect(width, height)
    --- @type Layout
    local layout = self._layouts:peek()
    self.last_rect = utils.Rect.new()

    if layout.dir == "tb" then
        local h = utils.parse_size(height, layout.rect.h, layout.offset)
        self.last_rect.x = layout.rect.x
        self.last_rect.y = layout.rect.y + layout.offset
        self.last_rect.w = layout.rect.w
        self.last_rect.h = h
        layout.offset = layout.offset + self.last_rect.h
    elseif layout.dir == "bt" then
        local h = utils.parse_size(height, layout.rect.h, layout.offset)
        self.last_rect.x = layout.rect.x
        self.last_rect.y = layout.rect.y + layout.rect.h - layout.offset
        self.last_rect.w = layout.rect.w
        self.last_rect.h = h
        layout.offset = layout.offset + self.last_rect.h
        self.last_rect.y = self.last_rect.y - self.last_rect.h
    elseif layout.dir == "lr" then
        local w = utils.parse_size(width, layout.rect.w, layout.offset)
        local h = utils.parse_size(height, layout.rect.h, 0)
        self.last_rect.x = layout.rect.x + layout.offset
        self.last_rect.y = layout.rect.y
        self.last_rect.w = w
        if layout.rect.h < h then
            local v_layout = self._layouts:peek_last(function(ele)
                return ele.dir == 'tb' or ele.dir == 'bt'
            end)
            local add = h - layout.rect.h
            v_layout.offset = v_layout.offset + add
            layout.rect.h = layout.rect.h + add
        end
        self.last_rect.h = h
        layout.offset = layout.offset + self.last_rect.w
    elseif layout.dir == "rl" then
        local w = utils.parse_size(width, layout.rect.w, layout.offset)
        local h = utils.parse_size(height, layout.rect.h, 0)
        self.last_rect.x = layout.rect.x + layout.rect.w - layout.offset
        self.last_rect.y = layout.rect.y
        self.last_rect.w = w
        if layout.rect.h < h then
            local v_layout = self._layouts:peek_last(function(ele)
                return ele.dir == 'tb' or ele.dir == 'bt'
            end)
            local add = h - layout.rect.h
            v_layout.offset = v_layout.offset + add
            layout.rect.h = layout.rect.h + add
        end
        self.last_rect.h = h
        self.last_rect.x = self.last_rect.x - self.last_rect.w
        layout.offset = layout.offset + self.last_rect.w
    end

    return self.last_rect
end

--- @param msg any
--- @param level 'info'|'warning'|'error'|nil
function GUI:debug(msg, level)
    if level == nil then
        level = 'info'
    end
    table.insert(self._debug_buffer, {
        msg = msg,
        level = level
    })
end

--- clear debug information
function GUI:debug_clear()
    self._debug_buffer = {}
end

--- @param name string
--- @param keys string[]
--- @param action fun()
function GUI:add_shortcut(name, keys, action)
    table.insert(self._keyboard_shortcuts, {
        name = name,
        keys = keys,
        action = action
    })
end

--- @param name string
function GUI:remove_shortcut(name)
    for i = #self._keyboard_shortcuts, 1, -1 do
        if self._keyboard_shortcuts[i].name == name then
            table.remove(self._keyboard_shortcuts, i)
        end
    end
end

function GUI:_draw_log_line()
    if #(self._debug_buffer) <= 0 then
        return
    end

    local ox, oy = term.getCursorPos()
    local _, h = term.getSize()
    local color = { info = colors.gray, warning = colors.orange, error = colors.red }
    term.setCursorPos(1, h)
    term.setTextColour(colors.white)
    for i = #self._debug_buffer, 1, -1 do
        local msg = tostring(self._debug_buffer[i].msg)
        local rect = utils.Rect.new()
        rect.x, rect.y = term.getCursorPos()
        rect.w, rect.h = #msg, 1
        if self:check_click(rect) then
            table.remove(self._debug_buffer, i)
            break
        end

        term.setBackgroundColor(color[self._debug_buffer[i].level])
        term.write(msg)
        term.setBackgroundColor(colors.black)
        term.write(" ")
    end

    term.setCursorPos(ox, oy)
end

function GUI:_draw_log_view()
    term.setBackgroundColor(self.theme:get('background'))
    term.clear()
    local color = { info = colors.black, warning = colors.orange, error = colors.red }
    local _, th = term.getSize()
    local count = 0
    for i = #self._debug_buffer, 1, -1 do
        count = count + 1
        local y = th - count + 1
        if y > 0 then
            term.setCursorPos(1, y)
            term.setBackgroundColor(color[self._debug_buffer[i].level])
            term.write(self._debug_buffer[i].msg)
        end
    end
end

function GUI:_check_keyboard_shortcuts()
    for i = 1, #(self._keyboard_shortcuts) do
        local targetKeys = self._keyboard_shortcuts[i].keys
        if #self._holding_keys ~= #targetKeys then
            goto continue
        end

        for j = 1, #targetKeys do
            if self._holding_keys[j] ~= targetKeys[j] then
                goto continue
            end
        end
        self._keyboard_shortcuts[i].action()
        :: continue ::
    end
end

--- @return boolean exit loop?
function GUI:_pull_event()
    local timerId = os.startTimer(.1)
    local event, param, x, y = os.pullEventRaw()
    os.cancelTimer(timerId)

    self._last_event = {
        name = event,
        args = { param, x, y }
    }

    if event == 'terminate' then
        local x, y = term.getSize()
        term.setCursorPos(1, y)
        return true
    elseif event == 'mouse_click' or event == 'mouse_drag' then
        self._hover = { x = x, y = y }
    elseif event == 'mouse_up' then
        self._hover = nil
    elseif event == 'key' then
        local has = false
        for i = 1, #(self._holding_keys) do
            if self._holding_keys[i] == param then
                has = true
                break
            end
        end
        if not has then
            table.insert(self._holding_keys, param)
            self:_check_keyboard_shortcuts()
        end
    elseif event == 'key_up' then
        local index = 0
        for i = 1, #(self._holding_keys) do
            if self._holding_keys[i] == param then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(self._holding_keys, index)
        end
    end
    return false
end

--- Start GUI with view function
--- @param view fun():(boolean|nil)
function GUI:start(view)
    self._end_loop = false
    self._last_event = {}
    local end_loop = false
    while not end_loop and not self._end_loop do
        local rect = utils.Rect.new()
        rect.x, rect.y = 1, 1
        rect.w, rect.h = term.getSize()
        self._layouts:push(utils.Layout.new(rect, 'tb'))

        self.theme:apply('')
        term.clear()

        end_loop = view() or end_loop
        if self.show_logs then
            self:_draw_log_view()
        else
            self:_draw_log_line()
        end
        end_loop = self:_pull_event() or end_loop

        self._layouts:pop()
    end

    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
end

--- Stop GUI
function GUI:stop()
    self._end_loop = true
end

return GUI
