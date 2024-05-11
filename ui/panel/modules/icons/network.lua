local wibox = require("wibox")
local oop = require("framework.oop")
local beautiful = require("beautiful")

local network = {}

function network:render()
  return wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.fonts:choose("icons", 12),
    markup = "",
    valign = "center",
    align = "center",
  })
end

return oop(network)
