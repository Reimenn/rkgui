local utils             = require 'rkgui.utils'
local components        = require 'rkgui.components'
local text_tools        = require 'rkgui.text'
local gui               = {}

--- styles
gui.colors              = require 'rkgui.theme.default' ()
--- @type Rect
gui.last_rect           = nil

--- @type Stack
gui._layouts            = utils.Stack.new()
--- @type {x:integer,y:integer}
gui._hover              = nil
--- @type {name:string,args:{[integer]:any}}
gui._last_event         = {}
--- @type {[integer]:{msg:string,level:integer}}
gui._debug_buffer       = {}
--- @type {name:string,keys:string[],action:fun()}[]
gui._keyboard_shortcuts = {}
--- @type integer[]
gui._hoding_keys        = {}
--- @type boolean
gui._end_loop           = false

--- @param name string
function gui.theme(name)
    gui.colors = (require 'rkgui.theme.default')()
    require('rkgui.theme.' .. name)()
end

--- Check if mouse hover on rect
--- @param rect Rect
--- @return boolean
function gui.check_mouse_holding(rect)
    return gui._hover and rect:point_in(gui._hover.x, gui._hover.y)
end

--- Check if mouse release on rect
--- @param rect Rect
--- @return boolean
function gui.check_click(rect)
    return (gui._last_event.name == 'mouse_up' and rect:point_in(gui._last_event.args[2], gui._last_event.args[3]))
        or (gui._last_event.name == 'monitor_touch' and rect:point_in(gui._last_event.args[2], gui._last_event.args[3]))
end

--- @param text string
--- @return boolean
function gui.button(text) return components.button(gui, text, false) end

--- @param text string
--- @return boolean
function gui.button_big(text) return components.button(gui, text, true) end

--- @param text string
--- @param align nil | 'l' | 'r' | 'c'
function gui.label(text, align) components.label(gui, text, align) end

--- @param text string
function gui.multiline_label(text)
    local total_w = gui._layouts:peek().rect.w
    local line = text_tools.wrap(text, total_w)
    for i = 1, #line do
        gui.label(line[i])
    end
end

--- @parma
--- @parma checked boolean
--- @return boolean
function gui.checkbox(text, checked) return components.checkbox(gui, text, checked) end

--- @param percent number [0,1]
--- @param show_percent boolean
function gui.progress_bar(percent, show_percent) components.progress_bar(gui, percent, show_percent) end

--- @param value number
--- @param min number
--- @param max number
--- @param integer boolean
--- @param show_number boolean
--- @return number
function gui.slider(value, min, max, integer, show_number)
    return components.slider(gui, value, min, max, integer, show_number)
end

--- @param selected integer
--- @param tabs {[integer]:string}
--- @return integer
function gui.tabs(selected, tabs) return components.tabs(gui, selected, tabs) end

function gui.space() gui.malloc_rect(1, 1) end

--- @param width integer | string
---@param height integer | string
---@param dir 'lr'|'rl'|'tb'|'bt'
---@param view fun()
local function draw_in_layout(width, height, dir, view)
    gui._layouts:push(utils.Layout.new(
        gui.malloc_rect(width, height),
        dir
    ))
    view()
    gui._layouts:pop()
end

--- Use `height` to specify the height of this row,
--- you can use numbers 1, 2, 3... to indicate the specific height,
--- or use a string such as "50%" to indicate the percentage height,
--- or use "+" to fill the remaining height.
--- @param height integer | string
--- @param view fun() Draw the UI in the function
function gui.row(height, view) draw_in_layout('+', height, 'lr', view) end

--- Like `row()` but reverse
--- @param height integer | string
--- @param view fun() Draw the UI in the function
function gui.reverse_row(height, view) draw_in_layout('+', height, 'rl', view) end

--- Use `width` to specify the width of this column,
--- you can use numbers 1, 2, 3... to indicate the specific width,
--- or use a string such as "50%" to indicate a percentage width,
--- or use "+" to fill the remaining width.
--- @param width integer | string
--- @param view fun() Draw the UI in the function
function gui.col(width, view) draw_in_layout(width, '+', 'tb', view) end

--- Like `col()` but reverse
--- @param width integer | string
--- @param view fun() Draw the UI in the function
function gui.reverse_col(width, view) draw_in_layout(width, '+', 'bt', view) end

--- @param width integer|string|nil
--- @param height integer|string|nil
--- @return Rect
function gui.malloc_rect(width, height)
    --- @type Layout
    local layout = gui._layouts:peek()
    gui.last_rect = utils.Rect.new()

    local w = utils.parse_size(width, layout.rect.w, layout.offset)
    local h = utils.parse_size(height, layout.rect.h, layout.offset)

    if layout.dir == "tb" then
        gui.last_rect.x = layout.rect.x
        gui.last_rect.y = layout.rect.y + layout.offset
        gui.last_rect.w = layout.rect.w
        gui.last_rect.h = h
        layout.offset = layout.offset + gui.last_rect.h
    elseif layout.dir == "bt" then
        gui.last_rect.x = layout.rect.x
        gui.last_rect.y = layout.rect.y + layout.rect.h - layout.offset
        gui.last_rect.w = layout.rect.w
        gui.last_rect.h = h
        layout.offset = layout.offset + gui.last_rect.h
        gui.last_rect.y = gui.last_rect.y - gui.last_rect.h
    elseif layout.dir == "lr" then
        gui.last_rect.x = layout.rect.x + layout.offset
        gui.last_rect.y = layout.rect.y
        gui.last_rect.w = w
        if layout.rect.h < h then
            local tb = gui._layouts:peek_last(function(ele) return ele.dir == 'tb' end)
            local add = h - gui.last_rect.h - 1
            tb.offset = tb.offset + add
            layout.rect.h = layout.rect.h + add
        end
        gui.last_rect.h = h
        layout.offset = layout.offset + gui.last_rect.w
    elseif layout.dir == "rl" then
        gui.last_rect.x = layout.rect.x + layout.rect.w - layout.offset
        gui.last_rect.y = layout.rect.y
        gui.last_rect.w = w
        if layout.rect.h < h then
            local tb = gui._layouts:peek_last(function(ele) return ele.dir == 'tb' end)
            local add = h - gui.last_rect.h - 1
            tb.offset = tb.offset + add
            layout.rect.h = layout.rect.h + add
        end
        gui.last_rect.h = h
        gui.last_rect.x = gui.last_rect.x - gui.last_rect.w
        layout.offset = layout.offset + gui.last_rect.w
    end

    return gui.last_rect
end

--- @param msg any
--- @param level? 'info'|'warnning'|'error'
function gui.debug(msg, level)
    if level == nil then level = 'info' end
    table.insert(gui._debug_buffer, {
        msg = msg,
        level = level
    })
end

--- clear debug information
function gui.debug_clear()
    gui._debug_buffer = {}
end

--- @param name string
--- @param keys string[]
--- @param action fun()
function gui.add_shortcut(name, keys, action)
    table.insert(gui._keyboard_shortcuts, {
        name = name,
        keys = keys,
        action = action
    })
end

--- @param name string
function gui.remove_shortcut(name)
    for i = #gui._keyboard_shortcuts, 1, -1 do
        if gui._keyboard_shortcuts[i].name == name then
            table.remove(gui._keyboard_shortcuts, i)
        end
    end
end

local function draw_debug()
    if #(gui._debug_buffer) <= 0 then return end

    local ox, oy = term.getCursorPos()
    local _, h = term.getSize()
    local color = { info = colors.gray, warnning = colors.orange, error = colors.red }
    term.setCursorPos(1, h)
    term.setTextColour(colors.white)
    for i = #gui._debug_buffer, 1, -1 do
        local msg = tostring(gui._debug_buffer[i].msg)
        local rect = utils.Rect.new()
        rect.x, rect.y = term.getCursorPos()
        rect.w, rect.h = #msg, 1
        if gui.check_click(rect) then
            table.remove(gui._debug_buffer, i)
            break
        end

        term.setBackgroundColor(color[gui._debug_buffer[i].level])
        term.write(msg)
        term.setBackgroundColor(colors.black)
        term.write(" ")
    end

    term.setCursorPos(ox, oy)
end

local function check_keyboard_shortcuts()
    for i = 1, #(gui._keyboard_shortcuts) do
        local targetKeys = gui._keyboard_shortcuts[i].keys
        if #gui._hoding_keys ~= #targetKeys then
            goto continue
        end

        for j = 1, #targetKeys do
            if gui._hoding_keys[j] ~= targetKeys[j] then
                goto continue
            end
        end
        gui._keyboard_shortcuts[i].action()
        ::continue::
    end
end

--- @return boolean exit loop?
local function pullEvent()
    local timerId = os.startTimer(.1)
    local event, param, x, y = os.pullEventRaw()
    os.cancelTimer(timerId)

    gui._last_event = {
        name = event,
        args = { param, x, y }
    }

    if event == 'terminate' then
        local x, y = term.getSize()
        term.setCursorPos(1, y)
        return true
    elseif event == 'mouse_click' or event == 'mouse_drag' then
        gui._hover = { x = x, y = y }
    elseif event == 'mouse_up' then
        gui._hover = nil
    elseif event == 'key' then
        local has = false
        for i = 1, #(gui._hoding_keys) do
            if gui._hoding_keys[i] == param then
                has = true
                break
            end
        end
        if not has then
            table.insert(gui._hoding_keys, param)
            check_keyboard_shortcuts()
        end
    elseif event == 'key_up' then
        local index = 0
        for i = 1, #(gui._hoding_keys) do
            if gui._hoding_keys[i] == param then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(gui._hoding_keys, index)
        end
    end
    return false
end

--- Start GUI with view function
--- @param view function
function gui.start(view)
    gui._end_loop = false
    local end_loop = false
    while not end_loop and not gui._end_loop do
        local rect = utils.Rect.new()
        rect.x, rect.y = 1, 1
        rect.w, rect.h = term.getSize()
        gui._layouts:push(utils.Layout.new(rect, 'tb'))

        term.setBackgroundColor(gui.colors.background)
        term.clear()

        end_loop = view() or end_loop
        draw_debug()
        end_loop = pullEvent() or end_loop

        gui._layouts:pop()
    end
    local _, h = term.getSize()
    term.setCursorPos(1, h)
end

--- Stop GUI
function gui.stop()
    gui._end_loop = true
end

return gui
