local gui = require 'rkgui'

local c = 3

gui.start_loop(function()
    if gui.button('click') then
        c = c + 1
    end
    gui.row_start()
    c = gui.slider(c, -10, 10, true, true)
    c = gui.slider(c, -10, 10, false, true)
    gui.row_end()
    gui.checkbox
    gui.label('end ' .. c, 'c')
end)
