local wibox = require("wibox")
local awful = require("awful")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Taglist = require("ui.panel.modules.taglist")

local _window = {}

function _window:constructor(s)
    self.s = s
    self:make_window()
end

function _window:make_window()
    local height = dpi(40)

    self.popup = awful.popup({
        type = "dock",
        visible = false,
        shape = utils:srounded(dpi(10)),
        bg = beautiful.colors.transparent,
        fg = beautiful.colors.foreground,
        x = self.s.geometry.x + beautiful.useless_gap * 2,
        y = self.s.geometry.y + beautiful.useless_gap * 2,
        minimum_width = self.s.geometry.width - beautiful.useless_gap * 4,
        maximum_width = self.s.geometry.width - beautiful.useless_gap * 4,
        minimum_height = height,
        maximum_height = height,
        widget = wibox.widget({
            widget = wibox.container.background,
            bg = beautiful.colors.background,
            shape = utils:srounded(dpi(10)),
            {
                layout = wibox.layout.stack,
                {
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.container.margin,
                        margins = utils:xmargins(8, 8, 10, 0),
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(10),
                            Taglist(self.s):render()
                        },
                    },
                    nil,
                },
                {
                    widget = wibox.container.place,
                    valign = "center",
                    halign = "center",
                    {
                        widget = wibox.widget.textbox,
                        markup = "",
                        valign = "center",
                        align = "center",
                    }
                },
            }
        }),
    })

    self.popup:struts({
        top = height + beautiful.useless_gap * 2,
    })
end

function _window:raise()
    self.popup.visible = true
end

return oop(_window)
