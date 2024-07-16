local awful = require("awful")
local Window = require("ui.panel.window")
local gtimer = require("gears.timer")
local panel_configuration = Configuration.UserLikes:get_key("panel")

if panel_configuration.enabled == false then
    return
end

gtimer.delayed_call(function()
    awful.screen.connect_for_each_screen(function(s)
        local window = Window(s)
        window:raise()
    end)
end)
