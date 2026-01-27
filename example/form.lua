-- Set the library search path
local rkgui_path = '/'
package.path = package.path .. ';' .. rkgui_path .. '?.lua;' .. rkgui_path .. '?/init.lua'

-- Load the rkgui and dialog module
local rkgui = require 'rkgui'
local dialog = require 'rkgui.dialog'

-- Create an RKGUI application instance
local app = rkgui.new()

-- Form data
local form_data = {
    name = 'John Doe',
    email = 'john@example.com',
    age = 30,
    subscribe = true,
    gender = 'male'
}

-- Gender options
local gender_options = { 'Male', 'Female', 'Prefer not to say' }
local gender_index = 1

-- Update gender index based on current value
local function update_gender_index()
    if form_data.gender == 'male' then
        gender_index = 1
    elseif form_data.gender == 'female' then
        gender_index = 2
    else
        gender_index = 3
    end
end

-- Initialize gender index
update_gender_index()

-- Start the render loop
app:start(function()
    app:title("Example Form App")
    
    -- Form title
    app:label("User Registration Form", 'c')
    app:space()
    
    -- Name field
    if app:button("Name: " .. form_data.name) then
        form_data.name = dialog.get_string(form_data.name, "Enter your name:") or form_data.name
    end
    app:space()
    
    -- Email field
    if app:button("Email: " .. form_data.email) then
        form_data.email = dialog.get_string(form_data.email, "Enter your email:") or form_data.email
    end
    app:space()
    
    -- Age field
    if app:button("Age: " .. tostring(form_data.age)) then
        local new_age = dialog.get_number(form_data.age, "Enter your age:", false) or form_data.age
        -- Check age range
        if new_age < 0 or new_age > 120 then
            dialog.alert("Age must be between 0 and 120")
            -- Clamp age to valid range
            new_age = math.max(0, math.min(120, new_age))
        end
        form_data.age = new_age
    end
    app:space()
    
    -- Gender selection using tabs
    app:label("Gender:")
    gender_index = app:tabs(gender_index, gender_options)
    
    -- Update gender value based on selected tab
    if gender_index == 1 then
        form_data.gender = 'male'
    elseif gender_index == 2 then
        form_data.gender = 'female'
    else
        form_data.gender = 'prefer_not_to_say'
    end
    app:space()
    
    -- Subscribe checkbox
    form_data.subscribe = app:checkbox("Subscribe to newsletter", form_data.subscribe)
    app:space()
    
    -- Submit button
    if app:button("Submit Form") then
        local gender_display = form_data.gender
        if gender_display == 'prefer_not_to_say' then
            gender_display = 'Prefer not to say'
        end
        local message = string.format(
            "Form submitted!\nName: %s\nEmail: %s\nAge: %d\nGender: %s\nSubscribe: %s",
            form_data.name, form_data.email, form_data.age, gender_display, 
            form_data.subscribe and "Yes" or "No"
        )
        dialog.alert(message)
    end
end)