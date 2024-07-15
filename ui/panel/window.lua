local wibox = require("wibox")
local awful = require("awful")
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Taglist = require("ui.panel.modules.taglist")
local Tasklist = require("ui.panel.modules.tasklist")
local Statusbar = require("ui.panel.modules.statusbar")

local _window = {}

function _window:constructor(s)
    self.s = s
    self:make_window()
end

function _window:make_window()
    local width = dpi(30)

    self.popup = awful.popup({
        type = "dock",
        visible = false,
        bg = beautiful.colors.transparent,
        fg = beautiful.colors.foreground,
        x = self.s.geometry.x,
        y = self.s.y,
        minimum_width = width,
        maximum_width = width,
        minimum_height = self.s.geometry.height,
        maximum_height = self.s.geometry.height,
        widget = wibox.widget({
            widget = wibox.widget.textbox,
            markup = "hello world",
        }),
    })

    self.popup:struts({
        left = width,
    })
end

function _window:raise()
    self.popup.visible = true
end

return oop(_window)
