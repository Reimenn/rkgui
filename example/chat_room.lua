-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the module
local rkgui = require 'rkgui'
local dialog = require 'rkgui.dialog'
local text_utils = require 'rkgui.text'

-- Function to open rednet modem
local function openRednetModem()
    -- Return if rednet is already open
    if rednet.isOpen() then
        return
    end

    -- Find modem peripheral
    local modem = peripheral.find("modem")
    -- If not found, create a virtual modem at the top
    if modem == nil then
        periphemu.create('top', 'modem', 'test')
        modem = peripheral.find("modem")
    end
    -- Open rednet connection
    rednet.open(peripheral.getName(modem))
end

-- Create rkgui application instance
local app = rkgui.new()
-- Chat channel name
local channel = 'chat-1234'
-- User name
local username = 'Who'
-- Whether joined the channel
local in_channel = false
-- Chat history, containing user and message
--- @type {user:string,message:string}[]
local history = { { user = "System", message = '----- welcom -----' } }
-- Input box text
local input_text = ''

-- Start page function, displays channel and user settings interface
local function startPage()
    app:title('RKGUI Example : Chat Room')
    app:row(1, function()
        app:label('Channel name: ' .. channel)
        app:reverse_row(1, function()
            -- Click change button to modify channel name
            if app:button('change', 1) then
                channel = dialog.get_string(channel, 'Input channel name.')
            end
        end)
    end)
    app:row(1, function()
        app:label('User name:    ' .. username)
        app:reverse_row(1, function()
            -- Click change button to modify user name
            if app:button('change', 1) then
                username = dialog.get_string(username, 'Input user name.')
            end
        end)
    end)
    app:space(2)
    app:row(3, function()
        app:col('30%', function() end)
        app:col('40%', function()
            -- Click Start Chat button to join the chat channel
            if app:button('Start Chat', 3) then
                openRednetModem()
                in_channel = true
            end
        end)
    end)
end

-- Chat channel page function, displays chat interface
local function channelPage()
    app:title('Channel: ' .. channel)
    -- Get buffer size
    local w, h = app.buffer:getSize()
    -- Custom layout to display chat history
    app:custom_layout('+', h - 4, 'bt', function()
        for i = 1, app.last_rect.h do
            local index = #history - i + 1
            if index > 0 then
                local message = history[index]
                app:label(message.user .. ': ' .. message.message)
            end
        end
    end)

    app:row(1, function()
        local text_width = w - 9
        local show_text = text_utils.left(input_text, text_width)
        -- Truncate text and show ellipsis if too long
        if #show_text > text_width then
            show_text = show_text:sub(1, text_width - 3) .. '...'
        end
        -- Show message, Click Edit button to edit message
        if app:button(show_text) then
            input_text = dialog.get_string(input_text, 'Input message.')
        end
        app:space(1)

        -- Click Send button to send message
        if app:button('Send') then
            local message = {
                user = username,
                message = input_text
            }
            -- Broadcast message to channel
            rednet.broadcast(message, channel)
            -- Add message to history
            table.insert(history, message)
            input_text = ''
        end
    end)

    -- Receive channel message
    local receive, message = rednet.receive(channel, 0.0001)
    if receive then
        -- Add received message to history
        table.insert(history, message)
    end
end

-- Start application main loop, display different pages based on in_channel status
app:start(function()
    if in_channel then
        channelPage()
    else
        startPage()
    end
end)
