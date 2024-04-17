local wibox = require("wibox")
local awful = require("awful")
local gshape = require("gears.shape")
local hoverable = require("ui.guards.hoverable")
local beautiful = require("beautiful")
local oop = require("framework.oop")

local _launcher = {}

function _launcher:render()
  local ring = hoverable(wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.colors.light_black_10,
    shape = gshape.circle,
    forced_width = 14,
    forced_height = 14,
    {
      widget = wibox.container.margin,
      margins = 2,
      {
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        shape = gshape.circle,
      }
    }
  })

  ring:setup_hover {
    colors = {
      normal = beautiful.colors.light_black_10,
      hovered = beautiful.colors.light_hovered_black_15
    }
  }

  local container = wibox.widget {
    widget = wibox.container.place,
    valign = "center",
    halign = "center",
    ring,
  }

  -- TODO: Here, we should call the system launcher (made with AWM)
  container:add_button(awful.button({}, 1, function ()
    require("naughty").notify({ title = "hello" })
  end))

  return container
end

return oop(_launcher)