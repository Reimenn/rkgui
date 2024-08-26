local gui = require 'rkgui'


local input = ''
gui.start_loop(function()
    if gui.button("[" .. input .. "]") then
        input = require('rkgui.input').get(gui, input, "Change Input:")
    end
end)
