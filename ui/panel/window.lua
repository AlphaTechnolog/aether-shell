local wibox = require("wibox")
local awful = require("awful")
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Taglist = require("ui.panel.modules.taglist")
local Tasklist = require("ui.panel.modules.tasklist")

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
    x = self.s.geometry.x + (beautiful.useless_gap * 2),
    y = self.s.geometry.y + (beautiful.useless_gap * 2),
    minimum_width = self.s.geometry.width - (beautiful.useless_gap * 4),
    maximum_width = self.s.geometry.width,
    minimum_height = height,
    maximum_height = height,
    widget = wibox.widget {
      layout = wibox.layout.stack,
      {
        layout = wibox.layout.align.horizontal,
        Taglist(self.s):render(),
      },
      {
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
        Tasklist(self.s):render(),
      }
    }
  }

  self.popup:struts {
    top = height + beautiful.useless_gap * 2
  }
end

function _window:raise()
  self.popup.visible = true
end

return oop(_window)