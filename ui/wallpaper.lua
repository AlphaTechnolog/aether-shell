local wibox = require("wibox")
local gfs = require("gears.filesystem")
local awful = require("awful")
local utils = require("framework.utils")()
local wallpaper = Configuration.UserLikes:get_key("wallpaper")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- TODO: Add support to solid background color only and tile wallpaper
Screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper({
    screen = s,
    widget = {
      widget = wibox.container.background,
      bg = beautiful.colors.background,
      valign = "center",
      halign = "center",
      {
        widget = wibox.container.margin,
        top = dpi(38),
        {
          widget = wibox.widget.imagebox,
          valign = "center",
          halign = "center",
          resize = true,
          horizontal_fit_policy = true,
          vertical_fit_policy = true,
          image = wallpaper.filename
            or gfs.get_configuration_dir() .. "/assets/wallpaper.png",
          clip_shape = utils:prounded(
            wallpaper.rounded_corners.roundness,
            wallpaper.rounded_corners.top_left,
            wallpaper.rounded_corners.top_right,
            wallpaper.rounded_corners.bottom_right,
            wallpaper.rounded_corners.bottom_left
          ),
        },
      },
    },
  })
end)
