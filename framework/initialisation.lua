local gtimer = require("gears.timer")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local autostart = require("framework.autostart")()
local oop = require("framework.oop")

local capi = {
  collectgarbage = collectgarbage,
}

local Initialisation = {}

function Initialisation:setup_garbage_collector_timer()
  capi.collectgarbage("setpause", 110)
  capi.collectgarbage("setstepmul", 1000)

  gtimer({
    timeout = 5,
    autostart = true,
    call_now = true,
    callback = function()
      collectgarbage("collect")
    end,
  })
end

function Initialisation:load_theme()
  local theme_file = gfs.get_configuration_dir() .. "theme.lua"
  beautiful.init(theme_file)
end

function Initialisation:load_autostart()
  gtimer.delayed_call(function()
    autostart:run()
  end)
end

return oop(Initialisation)
