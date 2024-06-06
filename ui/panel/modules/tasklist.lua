local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local hoverable = require("ui.guards.hoverable")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local dpi = beautiful.xresources.apply_dpi

local Tasklist = {}

local function Launcher()
  local container = hoverable(wibox.widget({
    widget = wibox.container.background,
    shape = gshape.squircle,
    bg = beautiful.colors.background,
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(5, 5, 6, 6),
      {
        widget = wibox.widget.imagebox,
        image = beautiful.distro,
        valign = 'center',
        halign = 'center',
        forced_width = dpi(20),
        forced_height = dpi(20),

        -- circled for awesomewm icon idk
        clip_shape = (
          beautiful:non_supported_distro_icon()
            and gshape.circle
            or nil
        ),
      }
    }
  }))

  container:setup_hover({
    colors = {
      normal = beautiful.colors.background,
      hovered = beautiful.colors.light_background_5
    },
  })

  container:add_button(awful.button({}, 1, function ()
    require("naughty").notify({ title = "todo" })
  end))

  return container
end

function Tasklist:render()
  local content_layout = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(6),
  })

  content_layout:add(Launcher())

  return wibox.widget({
    widget = wibox.container.margin,
    margins = utils:xmargins(2, 2, 0, 0),
    content_layout
  })
end

return oop(Tasklist)
