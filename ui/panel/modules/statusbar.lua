local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Network = require("ui.panel.modules.icons.network")
local Volume = require("ui.panel.modules.icons.volume")

local statusbar = {
  s = nil,
}

function statusbar:constructor(s)
  if not self.s then
    self.s = s
  end
end

local function clock()
  local text = wibox.widget({
    widget = wibox.widget.textbox,
  })

  gtimer({
    timeout = 10,
    call_now = true,
    autostart = true,
    single_shot = false,
    callback = function()
      text:set_markup_silently(os.date("%I:%M %p"))
    end,
  })

  local icon = wibox.widget({
    widget = wibox.container.background,
    fg = beautiful.colors.accent,
    {
      widget = wibox.widget.textbox,
      markup = "",
      font = beautiful.fonts:choose("icons", 10),
      valign = "center",
      align = "center",
    },
  })

  return wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.accent_shade,
    shape = utils:srounded(dpi(7)),
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(6, 6, 7, 7),
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(6),
        icon,
        text,
      },
    },
  })
end

local function layoutbox(self)
  return wibox.widget({
    widget = wibox.container.margin,
    margins = dpi(4),
    {
      widget = awful.widget.layoutbox,
      screen = self.s,
      buttons = {
        awful.button({}, 1, function()
          awful.layout.inc(1)
        end),
        awful.button({}, 3, function()
          awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
          awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
          awful.layout.inc(-1)
        end),
      },
    },
  })
end

local function contained(children)
  return wibox.widget({
    widget = wibox.container.margin,
    margins = dpi(7),
    children,
  })
end

function statusbar:render()
  return contained(wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(6),
    {
      widget = wibox.container.margin,
      right = dpi(6),
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(8),
        Network():render(),
        Volume():render(),
      },
    },
    clock(),
    layoutbox(self),
  }))
end

return oop(statusbar)
