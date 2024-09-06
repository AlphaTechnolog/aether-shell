local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("framework.utils")()
local animation = require("framework.animation")
local color = require("framework.color")
local oop = require("framework.oop")

local Layoutbox = {}

function Layoutbox:constructor(s)
    self.s = s
end

function Layoutbox:render()
    local layoutbox = awful.widget.layoutbox({
        screen = self.s,
    })

    local button = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.light_background_5,
        shape = utils:srounded(dpi(7)),
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end),
        },
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(5, 5, 6, 6),
            layoutbox,
        }
    })

    button.animation = animation:new({
        duration = 0.25,
        easing = animation.easing.linear,
        pos = color.hex_to_rgba(beautiful.colors.light_background_5),
        update = function (_, pos)
            button.bg = color.rgba_to_hex(pos)
        end,
    })

    function button.animation:set_color(new_color)
        self:set({ target = color.hex_to_rgba(new_color) })
    end

    button:connect_signal("mouse::enter", function (self)
        self.animation:set_color(beautiful.colors.light_background_15)
    end)

    button:connect_signal("mouse::leave", function (self)
        self.animation:set_color(beautiful.colors.light_background_5)
    end)

    return button
end

return oop(Layoutbox)