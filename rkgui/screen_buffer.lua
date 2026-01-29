--- @class ScreenBuffer
--- @field w number
--- @field h number
--- @field buffer {char: string, fg: string, bg: string}[]
--- @field cursor_x number
--- @field cursor_y number
--- @field cursor_blink boolean
--- @field cursor_color number
--- @field _fg number
--- @field _bg number
--- @field _fg_blit string
--- @field _bg_blit string
local ScreenBuffer = {}
ScreenBuffer.__index = ScreenBuffer

--- @param w number
--- @param h number
--- @return ScreenBuffer
function ScreenBuffer.new(w, h)
   local self = setmetatable({
      buffer = {},
      w = w,
      h = h,
      cursor_x = 1,
      cursor_y = 1,
      cursor_blink = false,
      cursor_color = term.getTextColor(),
      _fg = term.getTextColor(),
      _bg = term.getBackgroundColor(),
      _fg_blit = colors.toBlit(term.getTextColor()),
      _bg_blit = colors.toBlit(term.getBackgroundColor()),
   }, ScreenBuffer)
   self:resize(w, h)
   return self
end

function ScreenBuffer:setTextColor(color)
   self._fg = color
   self._fg_blit = colors.toBlit(color)
end

function ScreenBuffer:setBackgroundColor(color)
   self._bg = color
   self._bg_blit = colors.toBlit(color)
end

function ScreenBuffer:getTextColor()
   return self._fg
end

function ScreenBuffer:getBackgroundColor()
   return self._bg
end

function ScreenBuffer:setColor(fg, bg)
   self:setTextColor(fg)
   self:setBackgroundColor(bg)
end

function ScreenBuffer:setCursorColor(color)
   self.cursor_color = color
end

function ScreenBuffer:getCursorColor()
   return self.cursor_color
end

--- @param x number
--- @param y number
function ScreenBuffer:setCursorPos(x, y)
   self.cursor_x = x
   self.cursor_y = y
end

function ScreenBuffer:getCursorPos()
   return self.cursor_x, self.cursor_y
end

function ScreenBuffer:setCursorBlink(blink)
   self.cursor_blink = blink
end

function ScreenBuffer:getSize()
   return self.w, self.h
end

--- @param w number
--- @param h number
function ScreenBuffer:resize(w, h)
   self.w = w
   self.h = h
   while #self.buffer > self.h do
      table.remove(self.buffer, #self.buffer)
   end
   while #self.buffer < self.h do
      table.insert(self.buffer, {
         char = '',
         fg = '',
         bg = '',
      })
   end

   for i = 1, self.h do
      --- @type {char: string, fg: string, bg: string}
      local line = self.buffer[i]
      if #line.char > self.w then
         line.char = line.char:sub(1, self.w)
         line.fg = line.fg:sub(1, self.w)
         line.bg = line.bg:sub(1, self.w)
      end
      if #line.char < self.w then
         line.char = line.char .. string.rep(' ', self.w - #line.char)
         line.fg = line.fg .. string.rep(self._fg_blit, self.w - #line.fg)
         line.bg = line.bg .. string.rep(self._bg_blit, self.w - #line.bg)
      end
   end
end

function ScreenBuffer:write(text)
   self:blit(
      text,
      string.rep(self._fg_blit, #text),
      string.rep(self._bg_blit, #text)
   )
end

function ScreenBuffer:blit(text, fg, bg)
   if #text + self.cursor_x - 1 > self.w then
      text = text:sub(1, self.w - self.cursor_x + 1)
   end
   if #fg + self.cursor_x - 1 > self.w then
      fg = fg:sub(1, self.w - self.cursor_x + 1)
   end
   if #bg + self.cursor_x - 1 > self.w then
      bg = bg:sub(1, self.w - self.cursor_x + 1)
   end

   local line = self.buffer[self.cursor_y]
   if line == nil then
      return
   end
   line.char = line.char:sub(1, self.cursor_x - 1) .. text .. line.char:sub(self.cursor_x + #text)
   line.fg = line.fg:sub(1, self.cursor_x - 1) .. fg .. line.fg:sub(self.cursor_x + #fg)
   line.bg = line.bg:sub(1, self.cursor_x - 1) .. bg .. line.bg:sub(self.cursor_x + #bg)
   self.cursor_x = self.cursor_x + #text
end

function ScreenBuffer:drawFilledBox(x1, y1, x2, y2)
   for i = y1, y2 do
      self:setCursorPos(x1, i)
      self:write(string.rep(' ', x2 - x1 + 1))
   end
end

--- @param width number
--- @param height number
function ScreenBuffer:drawBorder(width, height)
   local bg = self:getBackgroundColor()
   local fg = self:getTextColor()
   local x, y = self:getCursorPos()
   self:setColor(bg, fg)
   self:write(string.char(159) .. string.rep(string.char(143), width - 2))
   self:setColor(fg, bg)
   self:write(string.char(144))

   self:setColor(bg, fg)
   for i = 1, height - 2 do
      self:setCursorPos(x, y + i)
      self:write(string.char(149))
   end
   self:setColor(fg, bg)
   for i = 1, height - 2 do
      self:setCursorPos(x + width - 1, y + i)
      self:write(string.char(149))
   end

   self:setCursorPos(x, y + height - 1)
   self:write(string.char(130))
   self:write(string.rep(string.char(131), width - 2))
   self:write(string.char(129))
end

--- @param width number
--- @param height number
function ScreenBuffer:drawBoldBorder(width, height)
   local bg = self:getBackgroundColor()
   local fg = self:getTextColor()
   local x, y = self:getCursorPos()
   self:setColor(bg, fg)
   self:write(string.rep(string.char(131), width))

   self:setBackgroundColor(fg)
   for i = 1, height - 2 do
      self:setCursorPos(x, y + i)
      self:write(' ')
      self:setCursorPos(x + width - 1, y + i)
      self:write(' ')
   end

   self:setCursorPos(x, y + height - 1)
   self:setColor(fg, bg)
   self:write(string.rep(string.char(143), width))
end

--- @param width number
--- @param height number
function ScreenBuffer:drawOuterBorder(width, height)
   local bg = self:getBackgroundColor()
   local fg = self:getTextColor()
   local x, y = self:getCursorPos()

   self:write(string.char(156))
   self:write(string.rep(string.char(140), width - 2))
   self:setColor(bg, fg)
   self:write(string.char(147))

   for i = 1, height - 2 do
      self:setCursorPos(x + width - 1, y + i)
      self:write(string.char(149))
   end
   self:setColor(fg, bg)
   for i = 1, height - 2 do
      self:setCursorPos(x, y + i)
      self:write(string.char(149))
   end

   self:setCursorPos(x, y + height - 1)
   self:write(string.char(141))
   self:write(string.rep(string.char(140), width - 2))
   self:write(string.char(142))
end

--- @param char string
--- @param width number
--- @param height number
function ScreenBuffer:drawCharBorder(char, width, height)
   local cx, cy = self:getCursorPos()
   self:write(string.rep(char, width))
   for i = 1, height - 2 do
      self:setCursorPos(cx, cy + i)
      self:write(char)
      self:setCursorPos(cx + width - 1, cy + i)
      self:write(char)
   end
   self:setCursorPos(cx, cy + height - 1)
   self:write(string.rep(char, width))
end

function ScreenBuffer:clear()
   for i = 1, self.h do
      local line = self.buffer[i]
      line.char = string.rep(' ', self.w)
      line.fg = string.rep(self._fg_blit, self.w)
      line.bg = string.rep(self._bg_blit, self.w)
   end
   self.cursor_x = 1
   self.cursor_y = 1
end

function ScreenBuffer:flush(target, offset_x, offset_y)
   for i = 1, self.h do
      target.setCursorPos(offset_x, offset_y + i - 1)
      local line = self.buffer[i]
      target.blit(line.char, line.fg, line.bg)
   end
   target.setCursorPos(offset_x + self.cursor_x - 1, offset_y + self.cursor_y - 1)
   target.setTextColor(self.cursor_color)
   target.setCursorBlink(self.cursor_blink)
end

return {
   ScreenBuffer = ScreenBuffer,
}
