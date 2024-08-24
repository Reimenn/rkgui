local gui = require 'rkgui'

local c = 0

local function ascii()
    gui.row_start()
    gui.label('000 ')
    for i = 100, 169 do
        if i % 15 == 0 then
            gui.row_end()
            gui.label(i .. ' ')
            gui.row_start()
            gui.label('       ')
        end
        if i % 5 == 0 then
            gui.label('   ')
        end
        gui.label(string.char(i) .. ' ')
    end
    gui.row_end()
end

gui.start_loop(function()
    gui.row_start()
    gui.button_big("!Big!")
    gui.row_end()
    gui.label("--")
end)
