local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local animation = require("framework.animation")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Tasklist = require("ui.dock.modules.tasklist")

local window = {}

local WINDOW_STATUS = {
  HIDDING = "HIDDING",
  SHOWING = "SHOWING",
  IDLE = "IDLE",
}

function window:constructor(s)
  self.s = s
  self.forced_opened = false
  self.status = WINDOW_STATUS.IDLE
  self.opened = false
  self:make_widget()
end

function window:get_widget()
  local container = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    border_color = beautiful.colors.light_black_15,
    border_width = dpi(1),
    shape = utils:srounded(dpi(12)),
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(6, 6, 8, 8),
      {
        layout = wibox.layout.fixed.horizontal,
        Tasklist(self.s):render(),
      },
    },
  })

  container:connect_signal("mouse::enter", function()
    self.forced_opened = true
    self:emit_signal("update_position")
  end)

  container:connect_signal("mouse::leave", function()
    self.forced_opened = false
    self:emit_signal("update_position")
  end)

  return container
end

function window:make_widget()
  local height = dpi(62)

  self.popup = awful.popup({
    screen = self.s,
    maximum_width = self.s.geometry.width - beautiful.useless_gap * 4,
    minimum_height = height,
    maximum_height = height,
    bg = beautiful.colors.transparent,
    fg = beautiful.colors.foreground,
    visible = false,
    ontop = true,
    widget = self:get_widget(),
  })

  self.popup.x = self.s.geometry.x
    + ((self.s.geometry.width - self.popup.width) / 2)

  self.popup.y = self.s.geometry.y
    + (self.s.geometry.height - beautiful.useless_gap * 2)

  function self.popup:repositionate(window)
    local function calculate()
      window:emit_signal("update_position")
    end

    calculate()

    self:connect_signal("property::width", function(_)
      calculate()
    end)

    self:connect_signal("property::height", function(_)
      calculate()
    end)
  end

  self.popup:repositionate(self)
  self:make_animation()
  self:apply_clients_listeners()
end

function window:make_animation()
  self.animation = animation:new({
    duration = 0.45,
    easing = animation.easing.inOutExpo,
    pos = {
      x = self.popup.x,
      y = self.popup.y,
    },
    update = function(_, pos)
      self.popup.x = pos.x
      self.popup.y = pos.y
    end,
    signals = {
      ["ended"] = function()
        self.status = WINDOW_STATUS.IDLE
      end,
    },
  })
end

function window:show_popup()
  self.status = WINDOW_STATUS.SHOWING

  self.animation:set({
    x = self.s.geometry.x + ((self.s.geometry.width - self.popup.width) / 2),
    y = self.s.geometry.y
      + (
        (self.s.geometry.height - self.popup.height)
        - beautiful.useless_gap * 2
      ),
  })

  self.opened = true
end

function window:hide_popup()
  -- just a little indicator of the current animation status, no really useful atm
  self.status = WINDOW_STATUS.HIDDING

  local offset = dpi(5)

  self.animation:set({
    x = self.s.geometry.x + ((self.s.geometry.width - self.popup.width) / 2),
    y = (self.s.geometry.y + self.s.geometry.height) - offset,
  })

  self.opened = false
end

local function should_hide_panel(self)
  if self.forced_opened then
    return false
  end

  if #self.s.selected_tag:clients() == 0 then
    return false
  end

  local curclient = Client.focus
  local is_floating = curclient.floating
    or awful.layout.get(self.s) == awful.layout.suit.floating

  if not is_floating or curclient.maximized then
    return true
  end

  local geo = {
    client = curclient:geometry(),
    dock = {
      x = self.popup.x,
      y = self.popup.y,
      width = self.popup.width,
      height = self.popup.height,
    },
  }

  return (
    geo.dock.x >= geo.client.x
    and geo.dock.x + geo.dock.width <= geo.client.x + geo.client.width
    and geo.dock.y <= geo.client.y + geo.client.height
  )
end

function window:apply_clients_listeners()
  local function update_state()
    gtimer.delayed_call(function()
      if should_hide_panel(self) then
        self:hide_popup()
      else
        self:show_popup()
      end

      self.s.dashboard:emit_signal("request::update_position")
    end)
  end

  Client.connect_signal("list", update_state)
  Client.connect_signal("property::active", update_state)
  Client.connect_signal("property::floating", update_state)
  Client.connect_signal("property::geometry", update_state)
  Tag.connect_signal("property::selected", update_state)
  Tag.connect_signal("property::layout", update_state)
  self:connect_signal("update_position", update_state)

  update_state()
end

function window:raise()
  self.popup.visible = true
end

function window:hide()
  self.popup.visible = false
end

return oop(window)
