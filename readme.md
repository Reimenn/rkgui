# RKGUI - A simple IMGUI-style TUI library for CraftOS

[中文版 Chinese edition](readme_zh.md)

RKGUI is a text-based GUI library for CraftOS / ComputerCraft / CC:Tweaked.
Its design is inspired by ImGui, allowing you to build interactive interfaces with very little code.

### Features

- Minimal API - no complex state management, widgets render immediately when called
- Rich set of components: buttons, text, input fields, dialogs, layouts
- Customizable themes with flexible color combinations
- Very easy to create your own custom components
- Touchscreen support - interact directly through monitors in the Minecraft world

Example: click a button to show Hello, World!:

```lua
local rkgui = require 'rkgui'
local dialog = require 'rkgui.dialog'

local app = rkgui.new()
app:start(function()
    if app:button("Click me!") then
        dialog.alert('Hello, World!')
    end
end)
```

### Component Showcase

> Run `demo.lua` in the `example` directory to see the full component showcase.
Here are some screenshots:

Labels, buttons, checkboxes, toggles:

![demo_base.png](images/demo_base.png)

Tabs, progress bars, sliders:

![demo_slider.png](images/demo_slider.png)

Confirmation dialog:

![dialog](images/dialog.png)

Text input:

![text-input](images/text_input.png)

Number input:

![number-input](images/number_input.png)

Flexible layout and styling:

![layout](images/layout_and_style.png)


