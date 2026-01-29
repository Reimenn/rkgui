local utils = require 'rkgui.utils'
local text_utils = require 'rkgui.text'

local module = {}

--- Industrial-themed components for RKGUI.
---
--- This file provides a small set of "industrial control panel" style widgets,
--- implemented on top of the core `GUI` API.
---
--- Usage:
---
--- ```lua
--- local GUI = require 'rkgui'
--- local industry = require 'rkgui.industry'
--- local gui = GUI.new()
--- local ind = industry.new(gui)
--- ```
local default_theme = {
    breaker = {
        border = {
            color = colors.orange,
        },
        track = colors.gray,
        handler = colors.white,
        open_color = colors.red,
        close_color = colors.green,
    },
    capacity_bar = {
        border = {
            color = colors.gray
        }
    }
}

--- @class IndustryComponents
--- @field gui GUI
local IndustryComponents = {}
IndustryComponents.__index = IndustryComponents

--- Create an industrial components helper bound to a GUI instance.
---
--- This will also install the default industrial theme table under the `industry` key.
--- @param gui GUI
--- @return IndustryComponents
function module.new(gui)
    gui.theme:set('industry', default_theme)
    return setmetatable({
        gui = gui
    }, IndustryComponents)
end

--- Draw a breaker switch widget and return the updated state.
---
--- @param is_break boolean Current breaker state (`true` = open/tripped, `false` = closed)
--- @param text string | nil Optional label rendered under the widget
--- @return boolean The updated breaker state
function IndustryComponents:breaker(is_break, text)
    local text_width = text and #text or 0
    local malloc_width = math.max(7, text_width)

    local draw = function()
        local rect = self.gui:malloc_rect(malloc_width, 5 + (text and 1 or 0))
        local center_x = rect.x + math.floor(rect.w * 0.5 - 3) + 1;
        local center_y = rect.y + 1

        -- Border
        self.gui.buffer:setCursorPos(center_x - 1, center_y - 1)
        self.gui:apply_style_to_buffer('industry.breaker.border')
        self.gui.buffer:drawBorder(7, rect.h - (text and 1 or 0))

        -- Click handling (toggle)
        local click_rect = utils.Rect.new()
        click_rect.w, click_rect.h = 5, 3
        click_rect.x, click_rect.y = center_x, center_y
        if self.gui:check_click(click_rect) then
            is_break = not is_break
        end

        -- Track
        self.gui.buffer:setBackgroundColor(self.gui.theme:get('industry.breaker.track'))
        self.gui.buffer:setCursorPos(center_x + 2, center_y)
        self.gui.buffer:write(' ')
        self.gui.buffer:setCursorPos(center_x + 2, center_y + 1)
        self.gui.buffer:write(' ')
        self.gui.buffer:setCursorPos(center_x + 2, center_y + 2)
        self.gui.buffer:write(' ')

        -- Handle / indicator
        self.gui.buffer:setBackgroundColor(self.gui.theme:get('industry.breaker.handler'))
        if self.gui:check_mouse_holding(click_rect) then
            self.gui.buffer:setCursorPos(center_x, center_y + 1)
            self.gui.buffer:write('     ')
        elseif is_break then
            self.gui.buffer:setCursorPos(center_x, center_y + 2)
            self.gui.buffer:write('     ')
            self.gui.buffer:setBackgroundColor(self.gui.theme:get('industry.breaker.background'))
            self.gui.buffer:setTextColor(self.gui.theme:get('industry.breaker.open_color'))
            self.gui.buffer:setCursorPos(center_x + 1, center_y + 1)
            self.gui.buffer:write(string.char(7))
        else
            self.gui.buffer:setCursorPos(center_x, center_y)
            self.gui.buffer:write('     ')
            self.gui.buffer:setBackgroundColor(self.gui.theme:get('industry.breaker.background'))
            self.gui.buffer:setTextColor(self.gui.theme:get('industry.breaker.close_color'))
            self.gui.buffer:setCursorPos(center_x, center_y + 1)
            self.gui.buffer:write(string.char(7))
        end

        if text then
            self.gui.buffer:setCursorPos(rect.x, rect.y + rect.h - 1)
            self.gui:draw_string_by_style('industry.breaker', text_utils.center(text, rect.w))
        end
    end

    draw()
    return is_break
end

--- Draw a vertical capacity bar.
---
--- `percent` is clamped to [0, 1]. The bar fills from bottom to top.
---
--- @param percent number Value in range [0,1]
--- @param width number|string Width specification (number, percentage like `"50%"`, or `"+"`)
--- @param height number|string Height specification (number, percentage like `"50%"`, or `"+"`)
--- @param text string|nil Optional label rendered under the bar
function IndustryComponents:capacity_bar(percent, width, height, text)
    percent = math.max(0, math.min(1, percent))
    width = self.gui:convert_width(width)
    height = self.gui:convert_height(height)
    local rect = self.gui:malloc_rect(math.max(width, text and #text or 0), height)
    local text_h = text and 1 or 0
    local bar_h = height - 2 - text_h
    self.gui:apply_style_to_buffer('industry.capacity_bar.border')
    self.gui.buffer:setCursorPos(rect.x, rect.y)
    self.gui.buffer:drawBorder(rect.w, rect.h - text_h)
    self.gui.buffer:drawFilledBox(rect.x + 1, rect.y + 1, rect.x + rect.w - 2, rect.y + height - 2 - text_h)
    local capacity_h = bar_h * percent

    for i = 1, capacity_h do
        self.gui.buffer:setBackgroundColor(self.gui.theme:get('industry.capacity_bar.color'))
        self.gui.buffer:setCursorPos(rect.x + 1, rect.y + rect.h - text_h - i - 1)
        self.gui.buffer:write(string.rep(' ', rect.w - 2))
    end

    local extend_pixel = math.floor((capacity_h % 1) * 3)
    if extend_pixel > 0 then
        self.gui.buffer:setColor(self.gui.theme:get('industry.capacity_bar.background'), self.gui.theme:get('industry.capacity_bar.color'))
        self.gui.buffer:setCursorPos(rect.x + 1, rect.y + rect.h - math.floor(capacity_h) - 2 - text_h)
        local char = extend_pixel == 1 and 143 or 131
        self.gui.buffer:write(string.rep(string.char(char), rect.w - 2))
    end

    if text then
        self.gui.buffer:setCursorPos(rect.x, rect.y + rect.h - 1)
        self.gui:draw_string_by_style('industry.capacity_bar', text_utils.center(text, rect.w))
    end
end

--- Run a small interactive demo for industrial widgets.
function module.demo()
    local app = require 'rkgui'.new()
    local industry = module.new(app)
    local breaked = false

    app:start(function()
        app:row(8, function()
            breaked = industry:breaker(breaked, "Breaker")
            industry:capacity_bar((os.clock() * 0.1) % 1, '+', '+', 'CAP')
        end)
    end)
end

return module