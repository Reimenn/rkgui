local gui = require 'rkgui'

local c = 3

gui.start_loop(function()
    gui.row_start()
    gui.label("Select: ")
    c = gui.tabs(c, { 'abc', 'ddd', 'cdef' })
    if c == 1 then
        gui.label("Select ABC")
    elseif c == 2 then
        gui.label("Select DDD")
    end
end)
