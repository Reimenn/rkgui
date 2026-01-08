--- @return string
local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then
        tmp = tmp .. name .. " = "
    end

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
--- @field x number
--- @field y number
--- @field w number
--- @field h number
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

--- @return string
function Rect:__tostring()
    return serializeTable(self)
end

--- @param x number
--- @param y number
--- @return boolean
function Rect:point_in(x, y)
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

--- @param where fun(ele):boolean
--- @return any | nil
function Stack:peek_last(where)
    for i = #self.data, 1, -1 do
        if where(self.data[i]) then
            return self.data[i]
        end
    end
    return nil
end

--- @return number
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

--- @class Layout
--- @field rect Rect
--- @field offset number
--- @field dir 'tb' | 'lr'
local Layout = {}
model.Layout = Layout
Layout.__index = model.Layout

function Layout.new(rect, dir)
    local inst = setmetatable({}, Layout)
    inst.rect = rect
    inst.offset = 0
    inst.dir = dir
    return inst
end

function model.shallow_copy(obj)
    local res = setmetatable({}, obj.__index)
    for k, v in pairs(obj) do
        res[k] = v
    end
    return res
end

--- @param value string | number | nil
--- @param max number
--- @param offset number
--- @return number
function model.parse_size(value, max, offset)
    if type(value) == "number" then
        return math.floor(value)
    end
    if type(value) == 'string' then
        if value == '+' then
            return math.floor(max - offset)
        end
        local last = value:sub(#value, #value)
        if last == '%' then
            value = value:sub(1, #value - 1)
            local percent = tonumber(value) / 100
            if percent then
                return math.floor(percent * max)
            end
        else
            local number = tonumber(value)
            if number then
                return math.floor(number)
            end
        end
    end
    return math.floor(max)
end

return model
