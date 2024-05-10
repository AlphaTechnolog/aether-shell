---@diagnostic disable: param-type-mismatch

pcall(require, 'luarocks.loader')

local beautiful = require('beautiful')
local gfs = require('gears.filesystem')
local gtimer = require('gears.timer')
local autostart = require('framework.autostart')()

local collectgarbage = collectgarbage

collectgarbage('setpause', 110)
collectgarbage('setstepmul', 1000)

gtimer({
  timeout = 5,
  autostart = true,
  call_now = true,
  callback = function()
    collectgarbage('collect')
  end,
})

require('awful.hotkeys_popup.keys')
require('awful.autofocus')
require('framework.configuration.exposer')
require('framework.globals')

local theme_file = gfs.get_configuration_dir() .. 'theme.lua'
beautiful.init(theme_file)

gtimer.delayed_call(function()
  autostart:run()
end)

require('misc.error-handling')
require('base')
require('ui')
