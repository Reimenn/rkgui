local gui = require 'rkgui'


local input = ''

gui.regist_shortcut("Test!", { keys.leftCtrl, keys.d }, function()
    gui.debug_info("CCC")
end)

gui.start_loop(function()
    if gui.button("[" .. input .. "]") then
        input = require('rkgui.input').get(gui, input, "Change Input:")
    end
end)
