local utils = require 'rkgui.utils'
local text_utils = require 'rkgui.text'

local model = {}
local default_theme = {
    breaker = {
        border = {
            color = colors.brown,
            char = string.char(127)
        },
        track = colors.gray,
        handler = colors.white,
        open_color = colors.red,
        close_color = colors.green,
    }
}

--- @class IndustryComponents
--- @field gui GUI
local IndustryComponents = {}
IndustryComponents.__index = IndustryComponents

--- @param gui GUI
--- @return IndustryComponents
function model.new(gui)
    gui.theme:set('industry', default_theme)
    return setmetatable({
        gui = gui
    }, IndustryComponents)
end

local set_term_color = function(fg, bg)
    term.setTextColor(fg)
    term.setBackgroundColor(bg)
end

--- @param width number
--- @param height number
local draw_border = function(width, height)
    local bg = term.getBackgroundColor()
    local fg = term.getTextColor()
    local x, y = term.getCursorPos()
    set_term_color(bg, fg)
    term.write(string.char(159))
    term.write(string.rep(string.char(143), width - 2))
    set_term_color(fg, bg)
    term.write(string.char(144))

    set_term_color(bg, fg)
    for i = 1, height - 2 do
        term.setCursorPos(x, y + i)
        term.write(string.char(149))
    end
    set_term_color(fg, bg)
    for i = 1, height - 2 do
        term.setCursorPos(x + width - 1, y + i)
        term.write(string.char(149))
    end

    term.setCursorPos(x, y + height - 1)
    term.write(string.char(130))
    term.write(string.rep(string.char(131), width - 2))
    term.write(string.char(129))
end

--- @param width number
--- @param height number
local draw_bold_border = function(width, height)
    local bg = term.getBackgroundColor()
    local fg = term.getTextColor()
    local x, y = term.getCursorPos()
    set_term_color(bg, fg)
    term.write(string.rep(string.char(131), width))

    term.setBackgroundColor(fg)
    for i = 1, height - 2 do
        term.setCursorPos(x, y + i)
        term.write(' ')
        term.setCursorPos(x + width - 1, y + i)
        term.write(' ')
    end

    term.setCursorPos(x, y + height - 1)
    set_term_color(fg, bg)
    term.write(string.rep(string.char(143), width))
end

--- @param width number
--- @param height number
local draw_outer_border = function(width, height)
    local bg = term.getBackgroundColor()
    local fg = term.getTextColor()
    local x, y = term.getCursorPos()

    term.write(string.char(156))
    term.write(string.rep(string.char(140), width - 2))
    set_term_color(bg, fg)
    term.write(string.char(147))

    for i = 1, height - 2 do
        term.setCursorPos(x + width - 1, y + i)
        term.write(string.char(149))
    end
    set_term_color(fg, bg)
    for i = 1, height - 2 do
        term.setCursorPos(x, y + i)
        term.write(string.char(149))
    end

    term.setCursorPos(x, y + height - 1)
    term.write(string.char(141))
    term.write(string.rep(string.char(140), width - 2))
    term.write(string.char(142))
end

--- @param char string
--- @param width number
--- @param height number
local draw_char_border = function(char, width, height)
    local cx, cy = term.getCursorPos()
    term.write(string.rep(char, width))
    for i = 1, height - 2 do
        term.setCursorPos(cx, cy + i)
        term.write(char)
        term.setCursorPos(cx + width - 1, cy + i)
        term.write(char)
    end
    term.setCursorPos(cx, cy + height - 1)
    term.write(string.rep(char, width))
end

--- @param is_break boolean
--- @param text string | nil
--- @return boolean
function IndustryComponents:breaker(is_break, text)
    local text_width = text and #text or 0
    local malloc_width = math.max(7, text_width)

    local draw = function()
        local rect = self.gui:malloc_rect(malloc_width, 5 + (text and 1 or 0))
        local center_x = rect.x + math.floor(rect.w * 0.5 - 3) + 1;
        local center_y = rect.y + 1

        -- draw border
        term.setCursorPos(center_x - 1, center_y - 1)
        self.gui.theme:apply('industry.breaker.border')
        draw_outer_border(7, rect.h - (text and 1 or 0))

        -- click check
        local click_rect = utils.Rect.new()
        click_rect.w, click_rect.h = 5, 3
        click_rect.x, click_rect.y = center_x, center_y
        if self.gui:check_click(click_rect) then
            is_break = not is_break
        end

        -- draw track
        term.setBackgroundColor(self.gui.theme:get('industry.breaker.track'))
        term.setCursorPos(center_x + 2, center_y)
        term.write(' ')
        term.setCursorPos(center_x + 2, center_y + 1)
        term.write(' ')
        term.setCursorPos(center_x + 2, center_y + 2)
        term.write(' ')

        -- draw handle
        term.setBackgroundColor(self.gui.theme:get('industry.breaker.handler'))
        if self.gui:check_mouse_holding(click_rect) then
            term.setCursorPos(center_x, center_y + 1)
            term.write('     ')
        elseif is_break then
            term.setCursorPos(center_x, center_y + 2)
            term.write('     ')
            term.setBackgroundColor(self.gui.theme:get('industry.breaker.background'))
            term.setTextColor(self.gui.theme:get('industry.breaker.open_color'))
            term.setCursorPos(center_x + 1, center_y + 1)
            term.write(string.char(7))
        else
            term.setCursorPos(center_x, center_y)
            term.write('     ')
            term.setBackgroundColor(self.gui.theme:get('industry.breaker.background'))
            term.setTextColor(self.gui.theme:get('industry.breaker.close_color'))
            term.setCursorPos(center_x, center_y + 1)
            term.write(string.char(7))
        end

        if text then
            term.setCursorPos(rect.x, rect.y + rect.h - 1)
            self.gui.theme:draw_string('industry.breaker', text_utils.center(text, rect.w))
        end
    end

    draw()
    return is_break
end

function model.demo()
    local app = require 'rkgui'.new()
    local industry = model.new(app)
    local breaked = false
    app:start(function()
        app:row(6, function()
            breaked = industry:breaker(breaked, "Breaker")
            app:space()
        end)
    end)
end

return model