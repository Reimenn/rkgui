return function()
    local t = require 'rkgui.theme.default' ()
    t:set('color', colors.black)
    t:set('background', colors.lightGray)
    t:set('light_color', colors.blue)
    
    t:set('button.background', '#light_color')
    t:set('button.holding.background', colors.gray)
    t:set('progress.bar.color', '#light_color')
    t:set('slider.indicator.background', '#light_color')
    t:set('slider.endpoint.color', '#light_color')
    return t
end