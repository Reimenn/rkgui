__BUILDED_MODULE__ = {
    MODULE = {},
    CACHE = {},
    --- @param name string
    REQUIRE = function(name)
        if __BUILDED_MODULE__.CACHE[name] == nil then
            local module_func = __BUILDED_MODULE__.MODULE[name]
            if module_func == nil then
                error("not found module " .. name)
            end
            __BUILDED_MODULE__.CACHE[name] = module_func()
        end
        return __BUILDED_MODULE__.CACHE[name]
    end
}
__BUILDED_MODULE__.MODULE['rkgui'] = function()
local core             = __BUILDED_MODULE__.REQUIRE('rkgui.utils')
local components       = __BUILDED_MODULE__.REQUIRE('rkgui.components')
local text_tools       = __BUILDED_MODULE__.REQUIRE('rkgui.text')
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
--- styles
gui.colors             = __BUILDED_MODULE__.REQUIRE('rkgui.theme.default')()

--- @param name string
function gui.theme(name)
    gui.colors = (__BUILDED_MODULE__.REQUIRE('rkgui.theme.default'))()
    require('rkgui.theme.' .. name)()
end

--- Check if mouse hover on rect
--- @param rect Rect
--- @return boolean
function gui.check_mouse_holding(rect)
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
function gui.button(text) return components.button(gui, text, false) end

--- @param text string
--- @return boolean
function gui.button_big(text) return components.button(gui, text, true) end

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
    if #(gui.debug_buffer) <= 0 then
        return
    end
    local ox, oy = term.getCursorPos()
    local _, h = term.getSize()
    local color = { colors.gray, colors.orange, colors.red }
    term.setCursorPos(1, h)
    for i = #gui.debug_buffer, 1, -1 do
        term.setBackgroundColor(color[gui.debug_buffer[i].level + 1])
        term.write(gui.debug_buffer[i].msg)
        term.setBackgroundColor(colors.black)
        term.write(" ")
    end
    term.setCursorPos(ox, oy)
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
    local end_loop = false
    while not end_loop do
        local rect = core.Rect.new()
        rect.x, rect.y = 1, 1
        rect.w, rect.h = term.getSize()
        gui.contaners_stack:push(rect)
        gui.offset_stack:push(0)
        gui.dir_stack:push('tb')

        term.setBackgroundColor(gui.colors.background)
        term.clear()

        end_loop = view() or end_loop
        draw_debug()
        end_loop = pullEvent() or end_loop

        gui.contaners_stack:pop()
        gui.offset_stack:pop()
        gui.dir_stack:pop()
    end
    local _, h = term.getSize()
    term.setCursorPos(1, h)
end

return gui

end

__BUILDED_MODULE__.MODULE['rkgui.utils'] = function()
--- @return string
local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local model = {}
--- @class Rect
--- @field x integer
--- @field y integer
--- @field w integer
--- @field h integer
local Rect = {}
model.Rect = Rect
Rect.__index = model.Rect


--- @return Rect
function Rect.new()
    local inst = setmetatable({}, Rect)
    inst.x = 0
    inst.y = 0
    inst.w = 0
    inst.h = 0
    return inst
end

--- @param self Rect
--- @return string
function Rect:__tostring()
    return serializeTable(self)
end

--- @param self Rect
--- @param x integer
--- @param y integer
--- @return boolean
function Rect:point_in(x,y)
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h
end

--- @class Stack
--- @field data table
local Stack = {}
model.Stack = Stack
Stack.__index = model.Stack

--- @return Stack
function Stack.new()
    local inst = setmetatable({}, Stack)
    inst.data = {}
    return inst
end

--- @return any
function Stack:pop()
    return table.remove(self.data, #self.data)
end

--- @return any
function Stack:peek()
    return self.data[#self.data]
end

--- @return integer
function Stack:size()
    return #self.data
end

--- @param value any
function Stack:push(value)
    self.data[#self.data + 1] = value
end

function Stack:clear()
    self.data = {}
end

function model.shallow_copy(obj) 
    local res = setmetatable({}, obj.__index)
    for k,v in pairs(obj) do
        res[k] = v
    end
    return res
end

return model

end

__BUILDED_MODULE__.MODULE['rkgui.components'] = function()
local text_tools = __BUILDED_MODULE__.REQUIRE('rkgui.text')
local utils = __BUILDED_MODULE__.REQUIRE('rkgui.utils')
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

end

__BUILDED_MODULE__.MODULE['rkgui.text'] = function()
--- @type fun(text:string, width:integer):string[]
local text_wrap = require('cc.strings').wrap


local text = {}

--- @param text string
--- @param width integer
--- @return string
function text.center(text, width)
    local space = width - #text
    local res = text
    if space > 0 then
        local left = space / 2
        res = string.rep(' ', left) .. text .. string.rep(' ', space - left)
    end
    if #res < width then
        res = res .. ' '
    end
    return res
end

--- @param text string
--- @param width integer
--- @return string
function text.right(text, width)
    local space = width - #text
    if space <= 0 then return text end
    return string.rep(' ', space) .. text
end

--- @param text string
--- @param width integer
--- @return string
function text.left(text, width)
    local space = width - #text
    if space <= 0 then return text end
    return text .. string.rep(' ', space)
end

--- @param source string
--- @param width integer
--- @return string[]
function text.wrap(source, width)
    return text_wrap(source, width)
end

--- @param source string
--- @param value string
--- @param pos integer
--- @return string
function text.insert(source, value, pos)
    source = source:sub(1, pos - 2) .. value .. source:sub(pos - 1)
    return source
end

--- @param source string
--- @param pos integer
--- @return string
function text.removeAt(source, pos)
    source = source:sub(1, pos - 1) .. source:sub(pos + 1)
    return source
end

return text

end

__BUILDED_MODULE__.MODULE['rkgui.theme.default'] = function()
return function()
    return {
        background = colors.black,
        button = {
            background = colors.gray,
            text = colors.white,
            holding = {
                background = colors.lightGray,
                text = colors.white,
            },
            click = {
                background = colors.black,
                text = colors.white,
            }
        },
        label = {
            background = colors.black,
            text = colors.white,
        },
        checkbox = {
            background = colors.black,
            text = colors.white,
            checked_box = colors.green,
            unchecked_box = colors.red,
            holding_box = colors.orange,
        },
        progress_bar = {
            background = colors.black,
            text = colors.white,
            bar_background = colors.gray,
            bar = colors.white
        },
        slider = {
            background = colors.black,
            text = colors.white,
            slider = colors.gray,
            indicator = colors.white,
        },
        tabs = {
            background = colors.gray,
            text = colors.black,
            selected = {
                background = colors.lightGray,
                text = colors.black,
            },
        }
    }
end

end

return __BUILDED_MODULE__.REQUIRE("rkgui")