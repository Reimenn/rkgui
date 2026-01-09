local gui = require('rkgui').new()
local input = require 'rkgui.input'

local n = 12
local t = 'hello'
gui:start(function()
    if gui:button('number ' .. tostring(n)) then
        n = input.get_number(n, 'Input Number:')
    end
    if gui:button('decimal ' .. tostring(n)) then
        n = input.get_number(n, 'Input Number:', true)
    end
    if gui:button('text ' .. t) then
        t = input.get_string(t, "Input Text:")
    end
end)

