-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the rkgui module
local rkgui = require 'rkgui'

-- Create an RKGUI application instance
local app = rkgui.new()

-- Tab state
local selected_tab = 1
local tabs = { "Basic", "Advanced" }

-- Start the render loop
app:start(function()
    -- Top tabs
    selected_tab = app:tabs(selected_tab, tabs, true)
    app:space()

    -- Tab content
    if selected_tab == 1 then
        -- Basic tab
        -- Basic row layout
        app:label("Basic Row Layout:")
        app:row(1, function()
            app:button("Button 1")
            app:space()
            app:button("Button 2")
            app:space()
            app:button("Button 3")
        end)
        app:space()

        -- Reverse row layout
        app:label("Reverse Row Layout:")
        app:reverse_row(1, function()
            app:button("First")
            app:space()
            app:button("Second")
            app:space()
            app:button("Third")
        end)
        app:space()

        -- Reverse column layout
        app:label("Reverse Column Layout:")
        app:reverse_col('+', function()
            app:button("Top")
            app:button("Middle")
            app:button("Bottom")
        end)
    elseif selected_tab == 2 then
        -- Advanced tab
        -- Complex nested layout (row containing columns)
        app:label("Complex Nested Layout:")
        app:row(5, function()
            app:col('40%', function()
                app:label("Left Column")
                app:space()
                app:button("Button A")
                app:space()
                app:button("Button B")
            end)
            app:space()
            app:col('+', function()
                app:label("Right Column")
                app:space()
                app:row(1, function()
                    app:button("X")
                    app:space()
                    app:button("Y")
                end)
                app:space()
                app:row(1, function()
                    app:button("Z")
                    app:space()
                    app:button("W")
                end)
            end)
        end)
        app:space()

        -- Variable width columns in row
        app:label("Variable Width Columns:")
        app:row(3, function()
            app:col('30%', function()
                app:label("30%")
                app:button("Narrow")
            end)
            app:space()
            app:col('+', function()
                app:label("Remaining")
                app:button("Wide")
            end)
        end)
        app:space()

        -- Spacing examples
        app:label("Spacing Examples:")
        app:row(1, function()
            app:button("A")
            app:space()
            app:button("B")
            app:space(2)
            app:button("C")
            app:space(3)
            app:button("D")
        end)
    end
end)
