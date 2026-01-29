-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the rkgui module
local rkgui = require 'rkgui'

-- Create an RKGUI application instance
local app = rkgui.new()

-- Initial counter value
local number = 0

-- Start the render loop
app:start(function()
    app:title("Example Debug App")
    
    app:row(1, function()
        if app:button(' Info ') then
            number = number + 1
            app:debug('Info ' .. tostring(number))
        end
        app:space()
        if app:button(' Warning ') then
            number = number + 1
            app:debug('Warning ' .. tostring(number), 'warning')
        end
        app:space()
        if app:button(' Error ') then
            number = number + 1
            app:debug('Error ' .. tostring(number), 'error')
        end
    end)
end)