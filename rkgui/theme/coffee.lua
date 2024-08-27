return function()
    local gui = require 'rkgui'

    local main_color = colors.brown
    local tip_color = colors.orange
    local text_color = colors.lightGray

    gui.colors.button.text = text_color
    gui.colors.button.background = main_color
    gui.colors.button.holding.background = main_color
    gui.colors.button.holding.text = colors.white
    gui.colors.button.click.background = tip_color

    gui.colors.checkbox.checked_box = main_color
    gui.colors.checkbox.holding_box = text_color

    gui.colors.tabs.background = main_color
    gui.colors.tabs.selected.background = tip_color

    gui.colors.label.text = text_color
    gui.colors.checkbox.text = text_color

    gui.colors.progress_bar.bar = main_color
    gui.colors.progress_bar.text = text_color

    gui.colors.slider.indicator = tip_color
    gui.colors.slider.text = text_color
end
