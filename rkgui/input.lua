local text_tool = require 'rkgui.text'

local input = {}

--- @param value string
--- @param title string
--- @return string
function input.get(gui, value, title)
    --- @module 'rkgui'
    gui = gui
    local source = value
    if value == nil then value = '' end

    local term_w, term_h = term.getSize()
    local left = math.max(2, math.floor(term_w * 0.2))
    local top = math.floor(term_h / 2)
    local text_w = term_w - left - left + 2

    local cursor = #value + 1
    local scroll = 1
    if cursor > text_w then
        scroll = cursor - text_w + 1
    end
    local function cursor_next()
        if cursor <= #value then
            cursor = cursor + 1
        end
        if cursor > text_w then
            scroll = cursor - text_w + 1
        end
    end
    local function cursor_move_left()
        if cursor > 1 then
            cursor = cursor - 1
        end
        while cursor - 5 < scroll and scroll > 1 do
            scroll = scroll - 1
        end
    end

    local ok = false
    gui.start_loop(function()
        -- update term size value
        term_w, term_h = term.getSize()
        left = math.max(2, math.floor(term_w * 0.2))
        top = math.floor(term_h / 2)
        text_w = term_w - left - left + 2

        -- input event
        local event = gui.last_event.name
        local param = gui.last_event.args[1]
        if event == 'key' then
            if param == keys.left then
                cursor_move_left()
            elseif param == keys.right then
                cursor_next()
            elseif param == keys.home then
                cursor = 1
                scroll = 1
            elseif param == keys['end'] then
                cursor = #value + 1
                if cursor > text_w then
                    scroll = cursor - text_w + 1
                end
            elseif param == keys.backspace and cursor > 1 then
                cursor_move_left()
                value = text_tool.removeAt(value, cursor)
            elseif param == keys.delete then
                value = text_tool.removeAt(value, cursor)
            elseif param == keys.enter then
                ok = true
                return true
            elseif param == keys.leftAlt or param == keys.rightAlt then
                ok = false
                return true
            end
        elseif event == 'char' then
            value = text_tool.insert(value, param, cursor + 1)
            cursor_next()
        end

        local prefix = string.rep(' ', left - 1)
        -- draw title
        for _ = 0, (term_h / 2) - 4 do
            gui.space()
        end
        -- draw title
        if title then
            gui.label(prefix .. title)
        else
            gui.label(prefix .. 'Input:')
        end
        gui.space()
        -- draw value
        local show_text = ""
        if scroll > 1 then
            show_text = prefix:sub(0, #prefix - 1) .. string.char(17)
        else
            show_text = prefix
        end
        show_text = show_text .. value:sub(scroll, scroll + text_w - 1)
        if scroll + text_w < #value + 1 then
            show_text = show_text .. string.char(16)
        end
        gui.label(show_text)
        -- draw underline
        gui.label(prefix .. string.rep(string.char(131), text_w))
        -- draw buttons
        local rt = false
        gui.row(1, function()
            gui.label(string.rep(' ', left - 1 + text_w - 17))
            if gui.button("Cancel") then
                ok = false
                rt = true
            end
            gui.space()
            if gui.button("Submit") then
                ok = true
                rt = true
            end
        end)

        -- cursor
        term.setCursorPos(left + cursor - scroll, top)
        term.setTextColor(colors.red)
        term.setCursorBlink(true)
        return rt
    end)

    term.setCursorBlink(false)
    if ok then
        return value
    else
        return source
    end
end

return input
