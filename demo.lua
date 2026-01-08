local GUI = require 'rkgui'
local themes = { 'default', 'light', 'coffee' }
local c_check = false
local c_check2 = true
local c_slider = 50
local c_tabs = 2
local c_counter = 0
local c_input_text = 'Hello World!'
local c_shortcut_counter = 0
local c_from = 1
local selected_page = 3

local gui = GUI.new()

local pages = {
    {
        name = "Welcom",
        draw = function()
            gui:space()
            gui:label("RKGUI", 'c')
            gui:label("--Rika ", 'r')
            gui:space()
            gui:multiline_label([[
This is a UI framework similar to IMGUI.

RKGUI can quickly create GUIs and automatically complete the layout, allowing you to focus more on program logic rather than UI logic.

Switch tabs at the top of the screen to see more content!
            ]])
        end
    },
    {
        name = "Demo1",
        draw = function()
            gui:space()
            gui:row(1, function()
                gui:label("Select theme:")
                for i, k in pairs(themes) do
                    if i > 1 then
                        gui:space()
                    end
                    if gui:button(k) then
                        local t = require('rkgui.theme.' .. k)()
                        gui.theme = t
                    end
                end
            end)
            gui:space()
            gui:label("i am a label", 'l')
            gui:label("i am a label", 'c')
            gui:label("i am a label", 'r')
            gui:space()
            if gui:button(("A button (%d)"):format(c_counter)) then
                c_counter = c_counter + 1
            end
            gui:space()
            if gui:button_big(("A BIG button (%d)"):format(c_counter)) then
                c_counter = c_counter + 1
            end
            gui:space()
            c_check = gui:checkbox("A check box", c_check)
            c_check2 = gui:toggle("Can change use [LeftCtrl + E]", c_check2)
            gui:space()
            gui:label("[LeftCtrl + LeftAlt + W] " .. c_shortcut_counter)
        end
    },
    {
        name = "Demo2",
        draw = function()
            gui:space()
            gui:label("A progress bar")
            gui:progress_bar((os.time()) % 1, true)
            gui:space()
            gui:label("A slider (33 to 99), can use mouse scroll")
            c_slider = gui:slider(c_slider, 33, 99, true, true)
            gui:space()
            gui:label("A tab group, like top at the screen")
            c_tabs = gui:tabs(c_tabs, { "One", "2", "San", "Yon", "alala" })

            gui:space()
            gui:label("Components in row")
            gui:row(1, function()
                gui:button("  >_<  ")
                gui:space()
                c_slider = gui:slider(c_slider, 33, 99, true, false)
                gui:space()
                c_check = gui:checkbox("A check box", c_check)
            end)

            gui:space()
            if gui:button("Click me to input text") then
                c_input_text = require('rkgui.input').get(c_input_text, "Input some text:")
            end
            gui:label(c_input_text)
        end,
    },
    {
        name = "Layout",
        draw = function()
            gui:row(1, function()
                gui:label("Left")
                gui:reverse_row(1, function()
                    gui:label("right")
                end)
            end)

            gui:row(8, function()
                gui:col('40%', function()
                    gui:space()
                    c_check = gui:checkbox("Checkbox")
                    gui:space()
                    gui:button("button")
                    gui:space()
                    c_slider = gui:slider(c_slider, 33, 99, false, false)
                end)
                gui:col('20%', function()
                end)
                gui:col('+', function()
                    for i = 1, 3 do
                        gui:label("Line " .. i)
                        gui:progress_bar(i / 3, false)
                    end
                end)
            end)
            gui:space()
            gui:button("One Line")

            local draw_tab = function()
                c_from = gui:tabs(c_from, { 'Left', 'Right' })
            end

            gui:label("Click change diraction:")
            if c_from == 1 then
                gui:row(1, draw_tab)
            else
                gui:reverse_row(1, draw_tab)
            end

            gui:reverse_col('+', function()
                gui:button("Bottom")
            end)
        end
    },
    {
        name = "About",
        draw = function()
            gui:space()
            gui:label('Project github', 'c')
            gui:label('https://github.com/Reimenn/rkgui', 'c')
            gui:space()
            gui:label('Author email', 'c')
            gui:label('rikarikari@qq.com', 'c')
        end
    }
}

gui:add_shortcut('change check2', { keys.leftCtrl, keys.e }, function()
    c_check2 = not c_check2
end)

gui:add_shortcut('change check2', { keys.leftCtrl, keys.leftAlt, keys.w }, function()
    c_shortcut_counter = c_shortcut_counter + 1
end)


gui:start(function()
    local tabs = {}
    for i = 1, #pages do
        table.insert(tabs, pages[i].name)
    end
    selected_page = gui:tabs(selected_page, tabs, true)
    pages[selected_page].draw()
end)
