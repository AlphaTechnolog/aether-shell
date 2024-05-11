local wibox = require("wibox")
local awful = require("awful")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

Client.connect_signal("request::titlebars", function(c)
  if c.requests_no_titlebar then
    return
  end

  -- local titlebar = awful.titlebar(c, {
  --   position = "top",
  --   size = dpi(33),
  --   bg = beautiful.colors.background,
  -- })

  -- titlebar:setup({
  --   layout = wibox.layout.stack,
  --   {
  --     widget = wibox.container.background,
  --     border_width = dpi(1),
  --     border_color = beautiful.colors.light_hovered_black_15,
  --     shape = utils:prounded(dpi(11), true, true, false, false),
  --     {
  --       widget = wibox.container.margin,
  --       bottom = dpi(1),
  --       {
  --         widget = wibox.widget.textbox,
  --         markup = "hello",
  --         valign = "center",
  --         align = "center",
  --       },
  --     },
  --   },
  --   {
  --     layout = wibox.layout.align.vertical,
  --     nil,
  --     nil,
  --     {
  --       widget = wibox.container.margin,
  --       left = dpi(1),
  --       right = dpi(1),
  --       {
  --         widget = wibox.container.background,
  --         hexpand = true,
  --         bg = beautiful.colors.background,
  --         forced_height = dpi(1),
  --       },
  --     },
  --   },
  -- })

  -- awful.titlebar(c, {
  --   position = "left",
  --   size = dpi(1),
  --   bg = beautiful.colors.light_hovered_black_15,
  -- })

  -- awful.titlebar(c, {
  --   position = "right",
  --   size = dpi(1),
  --   bg = beautiful.colors.light_hovered_black_15,
  -- })

  -- local bottom_titlebar = awful.titlebar(c, {
  --   position = "bottom",
  --   size = dpi(1),
  --   bg = beautiful.colors.light_hovered_black_15,
  -- })
end)
