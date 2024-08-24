local gui = require 'rkgui'

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

local c = 3

gui.start_loop(function()
    if gui.button('click') then
        c = c + 1
    end
    c = gui.slider(c, -10, 10, true, true)
    c = gui.slider(c, -10, 10, false, true)

    gui.label('end ' .. c, 'c')

    ascii()
end)
