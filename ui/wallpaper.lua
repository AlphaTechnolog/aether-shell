local wibox = require("wibox")
local gfs = require("gears.filesystem")
local awful = require("awful")
local utils = require("framework.utils")()
local wallpaper = Configuration.UserLikes:get_key("wallpaper")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- TODO: Add support to solid background color only and tile wallpaper
Screen.connect_signal("request::wallpaper", function(s)
  local shape = utils:prounded(
    wallpaper.rounded_corners.roundness,
    wallpaper.rounded_corners.top_left,
    wallpaper.rounded_corners.top_right,
    wallpaper.rounded_corners.bottom_right,
    wallpaper.rounded_corners.bottom_left
  )

  awful.wallpaper({
    screen = s,
    widget = {
      widget = wibox.container.background,
      bg = beautiful.colors.background,
      valign = "center",
      halign = "center",
      {
        widget = wibox.container.margin,
        bottom = dpi(40),
        {
          widget = wibox.container.background,
          border_width = dpi(1),
          border_color = beautiful.colors.light_background_15,
          shape = shape,
          {
            widget = wibox.widget.imagebox,
            valign = "center",
            halign = "center",
            resize = true,
            horizontal_fit_policy = true,
            vertical_fit_policy = true,
            clip_shape = shape,
            image = wallpaper.filename
              or gfs.get_configuration_dir() .. "/assets/wallpaper.png",
          },
        },
      },
    },
  })
end)
