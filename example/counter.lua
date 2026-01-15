-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the rkgui module
local rkgui = require 'rkgui'

-- Create an RKGUI application instance
local app = rkgui.new()

-- Initial counter value
local number = 10

-- Start the render loop
app:start(function()
    app:title("Example Counter App")
    
    app:label("Number: " .. tostring(number))
    app:space()
    
    -- Place buttons on the same row; the first parameter is the row height
    app:row(1, function()
        if app:button(' -1 ') then
            number = number - 1
        end
        app:space()
        if app:button(' +1 ') then
            number = number + 1
        end
    end)
end)