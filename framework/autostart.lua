local awful = require("awful")
local oop = require("framework.oop")

local _autostart = {}

function _autostart:run()
  for _, command in ipairs(Configuration.Autostart) do
    if type(command) == "string" then
      awful.spawn(command, false)
    end
  end
end

return oop(_autostart)
