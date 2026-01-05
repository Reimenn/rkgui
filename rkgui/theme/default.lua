return function()
    return {
        background = colors.black,
        button = {
            background = colors.gray,
            text = colors.white,
            holding = {
                background = colors.lightGray,
                text = colors.white,
            },
            click = {
                background = colors.black,
                text = colors.white,
            }
        },
        label = {
            background = colors.black,
            text = colors.white,
        },
        checkbox = {
            background = colors.black,
            text = colors.white,
            checked_box = colors.green,
            unchecked_box = colors.gray,
        },
        toggle = {
            background = colors.black,
            text = colors.white,
            toggle = colors.white,
            checked_box = colors.green,
            unchecked_box = colors.gray,
        },
        progress_bar = {
            background = colors.black,
            text = colors.white,
            bar_background = colors.gray,
            bar = colors.white
        },
        slider = {
            background = colors.black,
            text = colors.white,
            slider = colors.gray,
            indicator = colors.white,
        },
        tabs = {
            background = colors.gray,
            text = colors.black,
            selected = {
                background = colors.lightGray,
                text = colors.black,
            },
        }
    }
end
