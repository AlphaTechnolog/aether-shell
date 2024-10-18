local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Widget = require("ui.titlebars.widget")

Client.connect_signal("request::titlebars", function (c)
    local top_titlebar = awful.titlebar(c, {
        size = dpi(30),
        bg = beautiful.colors.light_background_1,
    })

    top_titlebar:setup(Widget(c):render())
end)