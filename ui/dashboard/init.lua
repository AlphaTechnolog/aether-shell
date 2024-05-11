local awful = require("awful")
local Window = require("ui.dashboard.window")
local gtimer = require("gears.timer")

gtimer.delayed_call(function()
  awful.screen.connect_for_each_screen(function(s)
    s.dashboard = Window(s)
  end)
end)
