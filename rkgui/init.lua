local core             = require 'rkgui.utils'
local components       = require 'rkgui.components'
local text_tools       = require 'rkgui.text'
local gui              = {}

gui.contaners_stack    = core.Stack.new()
gui.offset_stack       = core.Stack.new()
gui.dir_stack          = core.Stack.new()

--- @type {x:integer,y:integer}
gui.hover              = nil
--- @type {name:string,args:{[integer]:any}}
gui.last_event         = {}
--- @type {[integer]:{msg:string,level:integer}}
gui.debug_buffer       = {}
--- @type Rect
gui.last_rect          = nil
--- @type {name:string,keys:string[],action:fun()}[]
gui.keyboard_shortcuts = {}
--- @type integer[]
gui.hoding_keys        = {}

local function init()
    term.setBackgroundColor(colors.black)
    term.clear()
    local w, h = term.getSize()
    local rect = core.Rect.new()
    rect.x = 1
    rect.y = 1
    rect.w = w
    rect.h = h
    gui.contaners_stack:clear()
    gui.contaners_stack:push(rect)
    gui.offset_stack:clear()
    gui.offset_stack:push(0)
    gui.dir_stack:clear()
    gui.dir_stack:push('tb')
end

--- Check if mouse hover on rect
--- @param rect Rect
--- @return boolean
function gui.check_mouse_hover(rect)
    return gui.hover and rect:point_in(gui.hover.x, gui.hover.y)
end

--- Check if mouse release on rect
--- @param rect Rect
--- @return boolean
function gui.check_mouse_release(rect)
    return gui.last_event.name == 'mouse_up' and rect:point_in(gui.last_event.args[2], gui.last_event.args[3])
end

--- Check if mouse down on rect
--- @param rect Rect
--- @return boolean
function gui.check_mouse_down(rect)
    return gui.last_event.name == 'mouse_click' and rect:point_in(gui.last_event.args[2], gui.last_event.args[3])
end

--- @param text string
--- @return boolean
function gui.button(text) return components.button(gui, text) end

--- @param text string
--- @return boolean
function gui.button_big(text) return components.button_big(gui, text) end

--- @param text string
--- @param align nil | 'l' | 'r' | 'c'
function gui.label(text, align) components.label(gui, text, align) end

--- @param text string
function gui.multiline_label(text)
    local total_w = gui.contaners_stack:peek().w
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

function gui.row_start()
    gui.contaners_stack:push(gui.malloc_rect(1, 1))
    gui.offset_stack:push(0)
    gui.dir_stack:push('lr')
end

function gui.row_end()
    gui.contaners_stack:pop()
    gui.offset_stack:pop()
    gui.dir_stack:pop()
end

--- @param min_w integer
--- @param min_h integer
--- @return Rect
function gui.malloc_rect(min_w, min_h)
    local contaner = gui.contaners_stack:peek()
    local dir = gui.dir_stack:peek()
    local offset = gui.offset_stack:peek()
    gui.last_rect = core.Rect.new()

    gui.offset_stack:pop()
    if dir == "tb" then
        gui.last_rect.x = contaner.x
        gui.last_rect.y = contaner.y + offset
        gui.last_rect.w = contaner.w
        gui.last_rect.h = min_h
        gui.offset_stack:push(min_h + offset)
    elseif dir == "lr" then
        gui.last_rect.x = contaner.x + offset
        gui.last_rect.y = contaner.y
        gui.last_rect.w = min_w
        if contaner.h < min_h then
            local p2 = gui.offset_stack:pop()
            p2 = p2 + min_h - gui.last_rect.h - 1
            gui.offset_stack:push(p2)
            contaner.h = min_h
        end
        gui.last_rect.h = min_h
        gui.offset_stack:push(min_w + offset)
    end

    return gui.last_rect
end

--- @param msg string
--- display debug info at bottom of screen
function gui.debug_info(msg)
    gui.debug_raw(msg, 0)
end

--- @param msg string
--- display debug warnning at bottom of screen
function gui.debug_warnning(msg)
    gui.debug_raw(msg, 1)
end

--- @param msg string
--- display debug error at bottom of screen
function gui.debug_error(msg)
    gui.debug_raw(msg, 2)
end

--- clear debug infomations
function gui.debug_clear()
    gui.debug_buffer = {}
end

--- @param msg string
--- @param level integer
function gui.debug_raw(msg, level)
    gui.debug_buffer[#gui.debug_buffer + 1] = {
        msg = msg,
        level = level
    }
    if #gui.debug_buffer > 30 then
        table.remove(gui.debug_buffer, 0)
        table.remove(gui.debug_buffer, 0)
    end
end

--- @param name string
--- @param keys string[]
--- @param action fun()
function gui.regist_shortcut(name, keys, action)
    table.insert(gui.keyboard_shortcuts, {
        name = name,
        keys = keys,
        action = action
    })
end

--- @param name string
function gui.unregist_shotcut(name)
    for i = #gui.keyboard_shortcuts, 1, -1 do
        if gui.keyboard_shortcuts[i].name == name then
            table.remove(gui.keyboard_shortcuts, i)
        end
    end
end

--- draw debug info at bottom of the screen
local function draw_debug()
    local x, y = term.getSize()
    local color = { colors.gray, colors.orange, colors.red }
    term.setCursorPos(1, y)
    for i = #gui.debug_buffer, 1, -1 do
        term.setBackgroundColor(color[gui.debug_buffer[i].level + 1])
        term.write(gui.debug_buffer[i].msg)
        term.setBackgroundColor(colors.black)
        term.write(" ")
    end
end



local function check_keyboard_shortcuts()
    for i = 1, #(gui.keyboard_shortcuts) do
        local targetKeys = gui.keyboard_shortcuts[i].keys
        if #gui.hoding_keys ~= #targetKeys then
            goto continue
        end

        for j = 1, #targetKeys do
            if gui.hoding_keys[j] ~= targetKeys[j] then
                goto continue
            end
        end
        gui.keyboard_shortcuts[i].action()
        ::continue::
    end
end

--- @return boolean "exit loop?"
local function pullEvent()
    local timerId = os.startTimer(.1)
    local event, param, x, y = os.pullEventRaw()
    os.cancelTimer(timerId)

    gui.last_event = {
        name = event,
        args = { param, x, y }
    }

    if event == 'terminate' then
        local x, y = term.getSize()
        term.setCursorPos(1, y)
        return true
    elseif event == 'mouse_click' or event == 'mouse_drag' then
        gui.hover = { x = x, y = y }
    elseif event == 'mouse_up' then
        gui.hover = nil
    elseif event == 'key' then
        local has = false
        for i = 1, #(gui.hoding_keys) do
            if gui.hoding_keys[i] == param then
                has = true
                break
            end
        end
        if not has then
            table.insert(gui.hoding_keys, param)
            check_keyboard_shortcuts()
        end
    elseif event == 'key_up' then
        local index = 0
        for i = 1, #(gui.hoding_keys) do
            if gui.hoding_keys[i] == param then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(gui.hoding_keys, index)
        end
    end
    return false
end

--- @param view function
function gui.start_loop(view)
    while true do
        init()
        if view() then
            break
        end
        if #(gui.debug_buffer) > 0 then
            local x, y = term.getCursorPos()
            draw_debug()
            term.setCursorPos(x, y)
        end
        if pullEvent() then
            break
        end
    end
    gui.contaners_stack:pop()
    gui.offset_stack:pop()
    gui.dir_stack:pop()
    local w, h = term.getSize()
    term.setCursorPos(1, h)
end

return gui
