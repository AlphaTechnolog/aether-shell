local wibox = require("wibox")
local awful = require("awful")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Taglist = require("ui.panel.modules.taglist")
local Statusbar = require("ui.panel.modules.statusbar")

local _window = {}

function _window:constructor(s)
    self.s = s
    self:make_window()
end

function _window:make_window()
    local height = dpi(38)

    self.popup = awful.popup {
        type = "dock",
        visible = false,
        bg = beautiful.colors.transparent,
        fg = beautiful.colors.foreground,
        x = self.s.geometry.x,
        y = self.s.geometry.y,
        minimum_width = self.s.geometry.width,
        maximum_width = self.s.geometry.width,
        minimum_height = height,
        maximum_height = height,
        widget = wibox.widget {
            widget = wibox.container.background,
            bg = beautiful.colors.background,
            {
                layout = wibox.layout.stack,
                {
                    widget = wibox.container.place,
                    valign = 'center',
                    halign = 'right',
                    Statusbar(self.s):render()
                },
                {
                    widget = wibox.container.place,
                    halign = "center",
                    valign = "center",
                    Taglist(self.s):render(),
                }
            }
        }
    }

    self.popup:struts {
        top = height
    }
end

function _window:raise()
    self.popup.visible = true
end

return oop(_window)