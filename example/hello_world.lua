-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the rkgui and dialog module
local rkgui = require 'rkgui'
local dialog = require 'rkgui.dialog'

-- Create an RKGUI application instance
local app = rkgui.new()

-- Start the render loop
app:start(function()
    -- app:button draws a button with the given text.
    -- It returns true when the button is clicked.
    if app:button("Click me!") then
        dialog.alert('Hello, World!')
    end
end)