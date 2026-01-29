local text = require 'rkgui.text'

--- @class Theme
--- @field map table
local Theme = {}
Theme.__index = Theme

function Theme.new()
    local t = setmetatable({}, Theme)
    t.map = {}
    return t
end

--- @param key string
function Theme:get(key)
    local path = text.split(key, ".")
    local name = path[#path]
    table.remove(path, #path)
    local spaces = { self.map }
    for i = 1, #path do
        local n = spaces[#spaces][path[i]]
        if n == nil then
            break
        end
        table.insert(spaces, n)
    end

    local result
    for i = #spaces, 1, -1 do
        local v = spaces[i][name]
        if v ~= nil then
            result = v
            break
        end
    end

    if type(result) == "string" and result:sub(1, 1) == "#" then
        result = self:get(result:sub(2))
    end

    return result
end

--- @param path string
function Theme:set(path, value)
    path = text.split(path, ".")
    local name = path[#path]
    table.remove(path, #path)
    local spaces = { self.map }
    for i = 1, #path do
        local n = spaces[#spaces][path[i]]
        if type(n) ~= 'table' then
            n = {}
            spaces[#spaces][path[i]] = n
        end
        table.insert(spaces, n)
    end
    spaces[#spaces][name] = value
end

--- @param properties table<string, any>
--- @param func function()
function Theme:temp(properties, func)
    local reverse = {}
    for k in pairs(properties) do
        reverse[k] = self:get(k)
        local v = properties[k]
        if type(v) == 'string' and v:sub(1,1) == '$' then
            local path = v:sub(2)
            v = reverse[path]
            if v == nil then
                v = self:get(path)
            end
        end
        self:set(k, v)
    end
    func()
    for k in pairs(reverse) do
        self:set(k, reverse[k])
    end
end

return Theme
