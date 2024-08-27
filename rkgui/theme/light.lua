return function()
    local gui = require 'rkgui'


    gui.colors.background = colors.lightGray

    gui.colors.button.text = colors.black
    gui.colors.button.background = colors.blue
    gui.colors.button.holding.text = colors.black
    gui.colors.button.holding.background = colors.lightBlue
    gui.colors.button.click.text = colors.black
    gui.colors.button.click.background = colors.blue

    gui.colors.label.text = colors.black
    gui.colors.label.background = colors.lightGray

    gui.colors.checkbox.text = colors.black
    gui.colors.checkbox.background = colors.lightGray

    gui.colors.tabs.background = colors.gray
    gui.colors.tabs.selected.background = colors.blue

    gui.colors.progress_bar.text = colors.black
    gui.colors.progress_bar.background = colors.lightGray
    gui.colors.progress_bar.bar = colors.blue
    gui.colors.progress_bar.bar_background = colors.gray

    gui.colors.slider.text = colors.black
    gui.colors.slider.background = colors.lightGray
    gui.colors.slider.indicator = colors.blue
end
