local Theme = require 'rkgui.theme'

return function()
    local t = Theme.new()
    t.map = {
        background = colors.black,
        color = colors.white,
        button = {
            background = colors.gray,
            holding = {
                background = colors.lightGray,
                color = colors.white,
            },
            click = {
                background = colors.black,
                color = colors.white,
            },
            left_char = '[',
            right_char = ']'
        },
        label = {
        },
        checkbox = {
            checked = {
                color = colors.green,
                background = colors.green,
                char = ' '
            },
            unchecked = {
                color = colors.gray,
                char = string.char(127)
            },
        },
        toggle = {
            thumb = {
                color = colors.white,
                background = colors.white,
                char = ' '
            },
            track = {
                on = {
                    color = colors.green,
                    background = colors.green,
                    char = ' '
                },
                off = {
                    color = colors.gray,
                    char = string.char(127)
                }
            }
        },
        progress = {
            bar = {
                background = colors.gray,
                color = colors.white
            }
        },
        slider = {
            slider = {
                color = colors.gray,
                char = string.char(140)
            },
            endpoint = {
                color = colors.white
            },
            indicator = {
                color = colors.white,
                background = colors.white,
                char = ' '
            },
        },
        tabs = {
            background = colors.gray,
            color = colors.black,
            selected = {
                background = colors.lightGray,
                color = colors.black,
            },
        },
        keyboard = {
            danger_color = colors.red,
            primary_color = colors.green
        }
    }
    return t
end
