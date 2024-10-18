local awful = require("awful")
local Window = require("ui.panel.window")
local gtimer = require("gears.timer")
local panel_configuration = Configuration.UserLikes:get_key("panel")

if not panel_configuration.enabled then
    return
end

awful.screen.connect_for_each_screen(function (s)
    local window = Window(s)

    gtimer.delayed_call(function ()
        window:raise()
    end)
end)