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

return model
