local wibox = require("wibox")
local oop = require("framework.oop")
local beautiful = require("beautiful")

local volume = {}

function volume:render()
  return wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.fonts:choose("icons", 14),
    markup = "",
    valign = "center",
    align = "center",
  })
end

return oop(volume)
