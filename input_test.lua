local gui = require('rkgui').new()
local dialog = require 'rkgui.dialog'

local n = 12
local t = 'hello'
gui:start(function()
    if gui:button('number ' .. tostring(n)) then
        n = dialog.get_number(n, 'Input Number:')
    end
    if gui:button('decimal ' .. tostring(n)) then
        n = dialog.get_number(n, 'Input Number:', true)
    end
    if gui:button('text ' .. t) then
        t = dialog.get_string(t, "Input Text:")
    end
    if gui:button('message box') then
        dialog.alert(t, 'The quick brown fox jumps over the lazy dog, showcasing every letter of the English alphabet in a single sentence. When designing layouts')
    end
    if gui:button('no content box') then
        dialog.alert(t)
    end

    if gui:button('confirm') then
        gui:debug(dialog.confirm(t))
    end
    if gui:button('confirm') then
        gui:debug(dialog.confirm(t, "message"))
    end

    if gui:button('prompt') then
        gui:debug(dialog.prompt(t, "message"))
    end
end)

