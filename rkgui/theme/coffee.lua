return function()
    local t = require 'rkgui.theme.default' ()
    t:set('color', colors.lightGray)
    t:set('action_color', colors.brown)
    t:set('button.color', colors.white)
    t:set('progress.bar.color', colors.brown)
    t:set('slider.indicator.background', colors.brown)
    t:set('slider.endpoint.color', colors.brown)
    return t
end
