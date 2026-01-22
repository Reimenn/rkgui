-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

local GUI = require 'rkgui'
local Dialog = require 'rkgui.dialog'
local themes = { 'default', 'light', 'coffee' }
local c_check = false
local c_check2 = true
local c_slider = 50
local c_tabs = 2
local c_counter = 0
local c_input_text = 'Hello World!'
local c_input_number = 100
local c_shortcut_counter = 0
local selected_page = 1
 
local gui = GUI.new()

local pages = {
    {
        name = "Welcome",
        draw = function()
            gui:title("RKGUI", 'c')
            gui:space()
            gui:multiline_label([[
A simple IMGUI-style TUI library for CraftOS

RKGUI lets you build GUIs quickly and handles the layout automatically, so you can focus on program logic instead of UI details.

Switch the tabs at the top of the screen to explore more content!]])
            gui:space()
            gui:label('Project github', 'c')
            gui:label('https://github.com/Reimenn/rkgui', 'c')
        end
    },
    {
        name = "Base",
        draw = function()
            gui:space()
            gui:label("normal label")
            gui:label("center-aligned label", 'c')
            gui:label("right-aligned label", 'r')
            
            gui:space()
            if gui:button(("Im a counter button (%d)"):format(c_counter)) then
                c_counter = c_counter + 1
            end
            gui:space()
            if gui:button(("Im a BIG counter button (%d)"):format(c_counter), 3) then
                c_counter = c_counter + 1
            end
            
            gui:space()
            gui:label('You can press [LeftCtrl + E] to switch:')
            gui:space()
            c_check = gui:checkbox("Im a check box", c_check)
            c_check2 = gui:toggle("Im a toggle", c_check2)
            
            gui:space()
            gui:label("[LeftCtrl + LeftAlt + W] " .. c_shortcut_counter)
        end
    },
    {
        name = "More",
        draw = function()
            gui:space()
            gui:label("A progress bar")
            gui:progress_bar((os.time()) % 1, true)
            gui:space()
            gui:label("A slider (20 to 80), try use mouse scroll")
            c_slider = gui:slider(c_slider, 20, 80, true, true)
            gui:space()
            gui:label("A tab group, like one at top of the screen")
            c_tabs = gui:tabs(c_tabs, { "Tab1", "Tab2", "Tab3", "Tab4", "balaba" })

            gui:space()
            if gui:button('Ask me a question') then
                Dialog.confirm('Question:', 'Do you want to use RKGUI in CraftOS?')
            end

            gui:space()
            if gui:button("Click me to input text") then
                c_input_text = Dialog.get_string(c_input_text, "Input some text:")
            end
            gui:label(c_input_text)

            gui:space()
            if gui:button("Click me to input number") then
                c_input_number = Dialog.get_number(c_input_number, "Input Number:", true)
            end
            gui:label(tostring(c_input_number))
        end,
    },
    {
        name = "Style",
        draw = function()
            gui:row(1, function()
                gui:label("Left")
                gui:reverse_row(1, function()
                    gui:label("Right")
                end)
            end)

            gui:row(7, function()
                gui:col('45%', function()
                    gui:space()
                    c_check = gui:checkbox("Checkbox", c_check)
                    gui:space()
                    gui:button("button")
                    gui:space()
                    c_slider = gui:slider(c_slider, 20, 80, false, false)
                end)
                gui:space()
                c_slider = gui:vertical_slider(c_slider, 20, 80, false)
                gui:space()
                gui:col('+', function()
                    for i = 1, 3 do
                        gui:label("Line " .. i)
                        gui:progress_bar(i / 3, false)
                    end
                end)
            end)

            gui:space()
            gui:label("Components in row")
            gui:row(1, function()
                gui:button("  >_<  ")
                gui:space()
                c_slider = gui:slider(c_slider, 20, 80, true, false)
                gui:space()
                c_check = gui:checkbox("A check box", c_check)
            end)
            
            gui:space()
            gui:row(1, function()
                gui:label("Select theme: ")
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
            gui.theme:temp({
                ['background'] = colors.gray,
                ['button.background'] = colors.red
            }, function()
                gui:label('Change theme!')
                gui:row(1, function()
                    gui:button('red button')
                    gui:space()
                    gui.theme:set('button.background', '#submit_color')
                    gui:button('submit button')
                    gui:space()
                    gui.theme:set('button.background', '#background')
                    gui:button('ghost button')
                    gui:space()
                end)
            end)
            
            gui:space()
            gui:reverse_col('+', function()
                gui:button("On bottom")
            end)
        end
    }
}

gui:add_shortcut('change check', { keys.leftCtrl, keys.e }, function()
    c_check = not c_check
    c_check2 = not c_check2
end)

gui:add_shortcut('shortcut counter', { keys.leftCtrl, keys.leftAlt, keys.w }, function()
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
