local Theme = require 'rkgui.theme'

return function()
    local t = Theme.new()
    t.map = {
        background = colors.black,
        color = colors.white,
        danger_color = colors.red,
        submit_color = colors.green,
        ghost_color = colors.gray,
        action_color = colors.gray,
        button = {
            background = '#action_color',
            holding = {
                background = colors.lightGray,
            },
            click = {
                background = '#background',
            },
            left_char = '[',
            right_char = ']'
        },
        label = {
        },
        title = {
            line = '#ghost_color'
        },
        checkbox = {
            checked = {
                color = '#submit_color',
                background = '#submit_color',
                char = ' '
            },
            unchecked = {
                color = '#ghost_color',
                char = string.char(127)
            },
        },
        toggle = {
            thumb = {
                color = '#color',
                background = '#color',
                char = ' '
            },
            track = {
                on = {
                    color = '#submit_color',
                    background = '#submit_color',
                    char = ' '
                },
                off = {
                    color = '#ghost_color',
                    char = string.char(127)
                }
            }
        },
        progress = {
            bar = {
                background = '#ghost_color',
                color = '#color'
            }
        },
        slider = {
            slider = {
                color = '#ghost_color',
                char = string.char(140)
            },
            endpoint = {
                color = '#color'
            },
            indicator = {
                color = '#color',
                background = '#color',
                char = ' '
            },
        },
        tabs = {
            background = '#action_color',
            color = '#background',
            selected = {
                background = '#background',
                color = '#color',
            },
        },
    }
    return t
end
