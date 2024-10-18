local wibox = require("wibox")
local beautiful = require("beautiful")
local hoverable = require("ui.guards.hoverable")
local utils = require("framework.utils")()
local oop = require("framework.oop")

local Launcher = {}

function Launcher:render()
    local button = hoverable(wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(0, 0, 8, 8),
            {
                widget = wibox.widget.textbox,
                markup = "",
                font = beautiful.fonts:choose("icons", 12),
                valign = "center",
                align = "center",
            }
        }
    }))

    button:setup_hover({
        colors = {
            normal = beautiful.colors.background,
            hovered = beautiful.colors.light_background_5,
        }
    })

    button:add_button(utils:left_click(function ()
        require("naughty").notify({
            title = "sidebar"
        })
    end))

    return button
end

return oop(Launcher)