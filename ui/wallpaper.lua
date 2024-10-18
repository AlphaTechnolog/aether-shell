local wibox = require("wibox")
local gfs = require("gears.filesystem")
local awful = require("awful")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local wallpaper = Configuration.UserLikes:get_key("wallpaper")

Screen.connect_signal("request::wallpaper", function(s)
	if wallpaper.enable_default_splash then
		awful.wallpaper({
			screen = s,
			widget = {
				widget = wibox.container.background,
				bg = beautiful.colors.dark_background_1,
				{
					widget = wibox.container.place,
					valign = "center",
					halign = "center",
					{
						layout = wibox.layout.fixed.vertical,
						spacing = dpi(6),
						{
							widget = wibox.widget.textbox,
							markup = "<b>Default splash!</b>",
							font = beautiful.fonts:choose("monospace", 32),
							valign = "center",
							align = "center",
						},
						{
							widget = wibox.widget.textbox,
							markup = utils:build_markup {
								markup = "Work in progress",
								color = beautiful.colors.light_black_15,
								italic = true,
							},
							font = beautiful.fonts:choose("monospace", 14),
							valign = "center",
							align = "center",
						}
					}
				},
			},
		})
	else
		awful.wallpaper({
			screen = s,
			widget = {
				widget = wibox.widget.imagebox,
				valign = "center",
				halign = "center",
				resize = true,
				horizontal_fit_policy = true,
				vertical_fit_policy = true,
				image = wallpaper.filename
					or gfs.get_configuration_dir()
					.. "/assets/wallpaper.png",
			},
		})
	end
end)
