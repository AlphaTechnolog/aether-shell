-- TODO: Make a wallpaper manager which will perform some
-- customisations to the wallpaper like rounded edges and
-- more features rather than using the default one

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

Screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
    screen = s,
    widget = {
      {
        image = beautiful.wallpaper,
        upscale = true,
        downscale = true,
        widget = wibox.widget.imagebox,
      },
      valign = "center",
      halign = "center",
      tiled = false,
      widget = wibox.container.tile,
    }
  }
end)