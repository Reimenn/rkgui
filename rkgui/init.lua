local core          = require 'rkgui.utils'
local components    = require 'rkgui.components'

local gui           = {}

gui.contaners_stack = core.Stack.new()
gui.offset_stack    = core.Stack.new()
gui.dir_stack       = core.Stack.new()

--- @type {x:integer,y:integer}
gui.hover           = nil
--- @type {name:string,args:{[integer]:any}}
gui.last_event      = {}
--- @type {[integer]:{msg:string,level:integer}}
gui.debug_buffer    = {}

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

--- @param text string
--- @return boolean
function gui.button(text) return components.button(gui, gui.rect(1), text) end

--- @param text string
--- @param align nil | 'l' | 'r' | 'c'
function gui.label(text, align)
    if align == nil then align = 'l' end
    components.label(gui, gui.rect(1), text, align)
end

--- @parma text string
--- @parma checked boolean
--- @return boolean
function gui.checked(text, checked) return components.checkbox(gui, gui.rect(1), text,checked) end


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

--- @param size integer
--- @return Rect
function gui.rect(size)
    local contaner = gui.contaners_stack:peek()
    local dir = gui.dir_stack:peek()
    local offset = gui.offset_stack:peek()
    local rect = core.Rect.new()
    if dir == "tb" then
        rect.x = contaner.x
        rect.y = contaner.y + offset
        rect.w = contaner.w
        rect.h = size
    end
    gui.offset_stack:pop()
    gui.offset_stack:push(size + offset)
    return rect
end

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
    end
end

--- @param view function
function gui.start_loop(view)
    while true do
        init()
        view()
        draw_debug()
        if pullEvent() then
            break
        end
    end
end

return gui
