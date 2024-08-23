local gui = require 'rkgui'

local c = 0
local selected = false
gui.start_loop(function()
    if gui.button("Info") then
        c = c + 1
        gui.debug_info({ a = 23 })
    end
    if gui.button("Warning") then
        c = c + 1
        gui.debug_warnning("! awd")
    end
    if gui.button("Error") then
        c = c + 1
        gui.debug_error("Error:ajw")
    end
    if gui.button("Clear") then
        c = c + 1
        gui.debug_clear()
    end
    gui.label("Counter " .. c)
    gui.label("Counter " .. c, 'c')
    gui.label("Counter " .. c, 'r')

    selected = gui.checked("Test", selected)
end)
