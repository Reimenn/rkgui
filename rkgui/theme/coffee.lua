return function()
    local t = require 'rkgui.theme.default' ()
    t:set('color', colors.lightGray)
    t:set('button.background', colors.brown)
    t:set('tabs.background', colors.brown)
    t:set('tabs.selected.background', colors.brown)
    t:set('tabs.selected.color', colors.white)
    t:set('progress.bar.color', colors.brown)
    t:set('slider.indicator.background', colors.brown)
    t:set('slider.endpoint.color', colors.brown)
    return t
end
