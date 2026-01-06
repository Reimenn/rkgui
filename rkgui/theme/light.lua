return function()
    local t = require 'rkgui.theme.default' ()
    t:set('color', colors.black)
    t:set('background', colors.lightGray)

    t:set('tabs.background', colors.gray)
    t:set('tabs.selected.background', colors.lightGray)

    t:set('button.background', colors.gray)
    t:set('button.holding.background', colors.blue)
    t:set('button.click.background', colors.lightGray)
    
    t:set('progress.bar.color', colors.blue)
    t:set('slider.indicator.background', colors.blue)
    t:set('slider.endpoint.color', colors.blue)
    return t
end