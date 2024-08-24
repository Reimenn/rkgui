local gui = require 'rkgui'

gui.start_loop(function()
    local count = 17
    for i = 0, count do
        local offset = (os.time() * i) % 1
        gui.progress_bar(offset, true)
    end
end)
