local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Launcher = require("ui.panel.components.launcher")

local _window = {}

function _window:constructor(s)
  self.s = s
  self:make_window()
end

function _window:make_window()
  local width = dpi(self.s.geometry.width - 40)
  local height = dpi(40)

  self.popup = awful.popup {
    type = "dock",
    visible = false,
    bg = beautiful.colors.transparent,
    fg = beautiful.colors.foreground,
    x = (self.s.geometry.width - width) / 2,
    y = self.s.geometry.height - height,
    minimum_width = width,
    maximum_width = width,
    minimum_height = height,
    maximum_height = height,
    widget = wibox.widget {
      widget = wibox.container.background,
      bg = beautiful.colors.background,
      shape = utils:prounded(12, true, true, false, false),
      {
        layout = wibox.layout.stack,
        {
          layout = wibox.layout.align.horizontal,
          {
            widget = wibox.container.margin,
            left = dpi(13),
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(6),
              Launcher():render(),
            }
          },
          nil,
          {
            widget = wibox.container.margin,
            right = dpi(13),
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(6),
            }
          }
        },
        {
          widget = wibox.container.place,
          valign = "center",
          halign = "center",
          {
            widget = wibox.widget.textbox,
            markup = "center",
            valign = "center",
            align = "center",
          }
        }
      }
    }
  }

  self.popup:struts {
    bottom = height
  }
end

function _window:raise()
  self.popup.visible = true
end

return oop(_window)