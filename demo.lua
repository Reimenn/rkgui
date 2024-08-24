local gui = require 'rkgui'


local c_check = false
local c_slider = 50
local c_tabs = 2
local c_counter = 0
local selected_page = 1

local pages = {
    {
        name = "Welcom",
        draw = function()
            gui.space()
            gui.label("RKGUI", 'c')
            gui.label("--Rika ", 'r')
            gui.space()
            gui.multiline_label([[
This is a UI framework similar to IMGUI.

RKGUI can quickly create GUIs and automatically complete the layout, allowing you to focus more on program logic rather than UI logic.

Switch tabs at the top of the screen to see more content!
            ]])
        end
    },
    {
        name = "Demo1",
        draw = function()
            gui.label("i am a label", 'l')
            gui.label("i am a label", 'c')
            gui.label("i am a label", 'r')
            gui.space()
            if gui.button(("A button (%d)"):format(c_counter)) then c_counter = c_counter + 1 end
            gui.space()
            if gui.button_big(("A BIG button (%d)"):format(c_counter)) then c_counter = c_counter + 1 end
            gui.space()
            c_check = gui.checkbox("A check box", c_check)
        end
    },
    {
        name = "Demo2",
        draw = function()
            gui.space()
            gui.label("A progress bar")
            gui.progress_bar((os.time()) % 1, true)
            gui.space()
            gui.label("A slider (33 to 99)")
            c_slider = gui.slider(c_slider, 33, 99, true, true)
            gui.space()
            gui.label("A tab group, like top at the screen")
            c_tabs = gui.tabs(c_tabs, { "One", "2", "San", "Yon", "alala" })

            gui.space()
            gui.label("Components in row")
            gui.row_start()
            gui.button("  >_<  ")
            c_slider = gui.slider(c_slider, 33, 99, true, false)
            c_check = gui.checkbox("A check box", c_check)

            gui.row_end()
        end
    },
    {
        name = "About",
        draw = function()
            gui.space()
            gui.label('Project github', 'c')
            gui.label('https://github.com/Reimenn/rkgui', 'c')
            gui.space()
            gui.label('Author email', 'c')
            gui.label('rikarikari@qq.com', 'c')
        end
    }
}

gui.start_loop(function()
    local tabs = {}
    for i = 1, #pages do table.insert(tabs, pages[i].name) end
    selected_page = gui.tabs(selected_page, tabs)
    pages[selected_page].draw()
end)
