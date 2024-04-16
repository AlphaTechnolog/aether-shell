pcall(require, "luarocks.loader")

local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gtimer = require("gears.timer")
local autostart = require("framework.autostart")()

require("awful.hotkeys_popup.keys")
require("awful.autofocus")
require("framework.configuration.exposer")
require("framework.globals")

local theme_file = gfs.get_configuration_dir() .. "theme.lua"
beautiful.init(theme_file)

gtimer.delayed_call(function ()
  autostart:run()
end)

require("misc.error-handling")
require("base.layouts")
require("base.wallpaper")
require("base.tags")
require("base.keybindings")
require("base.rules")
require("base.sloppy_focus")
require("base.notifications")
require("base.sloppy_focus")