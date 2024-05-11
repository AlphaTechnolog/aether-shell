local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local animation = require("framework.animation")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local window = {}

function window:constructor(s)
  self.s = s
  self:make_popup()
  self:create_animations()
  self:subscriptions()
end

local WindowPosition = {
  Opened = "Opened",
  Closed = "Closed",
}

local preferred_dimensions = {
  width = dpi(740),
  height = dpi(620),
}

local positions = {
  [WindowPosition.Opened] = function(self)
    local s = self.s

    local width, height =
      preferred_dimensions.width, preferred_dimensions.height

    local dock = s.dock

    local dim = {
      x = s.geometry.x + ((s.geometry.width - width) / 2),
      y = (s.geometry.y + ((s.geometry.height - height) / 2)),
    }

    if dock.opened then
      dim.y = dim.y - dpi(15)
    end

    return dim
  end,
  [WindowPosition.Closed] = function(self)
    local s = self.s
    local width = preferred_dimensions.width

    return {
      x = s.geometry.x + ((s.geometry.width - width) / 2),
      y = s.geometry.y + (s.geometry.height + beautiful.useless_gap * 2),
    }
  end,
}

function window:get_widget()
  return wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    shape = utils:srounded(dpi(12)),
    border_width = dpi(1),
    border_color = beautiful.colors.light_black_15,
    {
      widget = wibox.container.margin,
      margins = dpi(7),
      {
        widget = wibox.widget.textbox,
        markup = "hello",
        align = "center",
        valign = "center",
      },
    },
  })
end

function window:make_popup()
  local width, height = preferred_dimensions.width, preferred_dimensions.height

  self.dashboard = awful.popup({
    screen = self.s,
    visible = false,
    ontop = true,
    bg = beautiful.colors.transparent,
    fg = beautiful.colors.foreground,
    minimum_width = width,
    minimum_height = height,
    widget = self:get_widget(),
  })

  gtimer.delayed_call(function()
    local get_position = positions[WindowPosition.Closed]

    for key, val in pairs(get_position(self)) do
      self.dashboard[key] = val
    end
  end)
end

local WindowStatus = {
  Opening = "Opening",
  Closing = "Closing",
  Idle = "Idle",
}

function window:create_animations()
  local get_default_position = positions[WindowPosition.Closed]
  local window_position = get_default_position(self)

  self.dashboard.status = WindowStatus.Idle

  self.dashboard.animation = animation:new({
    duration = 0.45,
    easing = animation.easing.inOutExpo,
    pos = {
      x = window_position.x,
      y = window_position.y,
    },
    update = function(_, pos)
      self.dashboard.x = pos.x
      self.dashboard.y = pos.y
    end,
    signals = {
      ["ended"] = function()
        if self.dashboard.status == WindowStatus.Closing then
          self.dashboard.visible = false
        end

        self.dashboard.status = WindowStatus.Idle
      end,
    },
  })
end

function window:raise()
  self.dashboard.status = WindowStatus.Opening
  self.dashboard.visible = true

  local get_new_position = positions[WindowPosition.Opened]
  local new_window_position = get_new_position(self)

  if not self.dashboard.animation then
    error(
      "[internal::dashboard] self.dashboard.animation() haven't been created yet."
    )
  end

  self.dashboard.animation:set({
    x = new_window_position.x,
    y = new_window_position.y,
  })
end

function window:hide()
  self.dashboard.status = WindowStatus.Closing

  local get_new_position = positions[WindowPosition.Closed]
  local new_window_position = get_new_position(self)

  if not self.dashboard.animation then
    error(
      "[internal::dashboard] self.dashboard.animation() haven't been created yet."
    )
  end

  self.dashboard.animation:set({
    x = new_window_position.x,
    y = new_window_position.y,
  })
end

function window:toggle()
  if self.dashboard.status ~= WindowStatus.Idle then
    return
  end

  if self.dashboard.visible == true then
    return self:hide()
  end

  if self.dashboard.visible == false then
    return self:raise()
  end
end

function window:subscriptions()
  -- this is prolly called by the dock who wants to claim the used
  -- space when it gets opened by the user
  self:connect_signal("request::update_position", function()
    if self.dashboard.status ~= WindowStatus.Idle then
      return
    end

    if not self.dashboard.visible then
      return
    end

    local calculate_new_position = positions[WindowPosition.Opened]
    local new_position = calculate_new_position(self)

    self.dashboard.animation:set({
      x = new_position.x,
      y = new_position.y,
    })
  end)
end

return oop(window)
