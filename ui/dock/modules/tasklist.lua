-- TODO: This module could be improved to add pinned dock entries, grouped dock entries
-- drag and drop new clients, etc...

local wibox = require("wibox")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local hoverable = require("ui.guards.hoverable")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local animation = require("framework.animation")
local color = require("framework.color")
local icon_theme = require("framework.icon-theme")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local tasklist = {
  s = nil,
}

function tasklist:constructor(s)
  self.s = s
end

local function Launcher(self)
  local container = hoverable(wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    fg = beautiful.colors.accent,
    shape = utils:srounded(dpi(8)),
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(6, 6, 10, 10),
      {
        widget = wibox.widget.textbox,
        markup = "",
        font = beautiful.fonts:choose("icons", 24),
        valign = "center",
        align = "center",
      },
    },
  }))

  container:setup_hover({
    colors = {
      normal = beautiful.colors.background,
      hovered = beautiful.colors.light_background_10,
    },
  })

  container:add_button(utils:left_click(function()
    local dashboard = self.s.dashboard

    if not dashboard then
      return
    end

    gtimer.delayed_call(function()
      dashboard:toggle()
    end)
  end))

  return container
end

local function ClientButton(client)
  local container = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    shape = utils:srounded(dpi(7)),
    {
      layout = wibox.layout.align.vertical,
      nil,
      {
        widget = wibox.container.margin,
        margins = dpi(4),
        {
          widget = wibox.widget.imagebox,
          image = icon_theme:get_client_icon_path(client),
          valign = "center",
          halign = "center",
          forced_width = dpi(42),
          forced_height = dpi(42),
        },
      },
      {
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        {
          id = "indicator-element",
          widget = wibox.container.background,
          bg = beautiful.colors.background,
          forced_height = dpi(4),
          forced_width = dpi(4),
          shape = gshape.rounded_bar,
        },
      },
    },
  })

  local indicator = container:get_children_by_id("indicator-element")[1]

  if not indicator then
    print(
      "[warning] cannot find indicator in tasklist for client " .. client.title
    )
    return
  end

  container.animation = animation:new({
    duration = 0.25,
    easing = animation.easing.inOutQuad,
    pos = {
      bg = color.hex_to_rgba(beautiful.colors.background),
      indicator = color.hex_to_rgba(beautiful.colors.background),
      indicator_width = 4,
    },
    update = function(_, pos)
      if pos == nil then
        return
      end

      if pos.bg ~= nil then
        container.bg = color.rgba_to_hex(pos.bg)
      end

      if pos.indicator ~= nil then
        indicator.bg = color.rgba_to_hex(pos.indicator)
      end

      if pos.indicator_width ~= nil then
        indicator.forced_width = dpi(pos.indicator_width)
      end
    end,
  })

  function container.animation:set_color(state)
    self:set({
      bg = state.bg and color.hex_to_rgba(state.bg) or nil,
      indicator = state.indicator and color.hex_to_rgba(state.indicator) or nil,
      indicator_width = state.indicator_width or nil,
    })
  end

  local function subscribed(key, callback)
    local function set_value()
      gtimer.delayed_call(function()
        if callback ~= nil then
          callback()
        end
      end)
    end

    set_value()
    client:connect_signal("property::" .. key, set_value)
  end

  subscribed("active", function()
    gtimer.delayed_call(function()
      container.animation:set_color({
        indicator_width = client.active and 22 or 4,
        indicator = client.active and beautiful.colors.accent
          or beautiful.colors.background,
        bg = client.active and beautiful.colors.light_background_10
          or beautiful.colors.background,
      })
    end)
  end)

  container:connect_signal("mouse::enter", function()
    if client.active then
      container.animation:set_color({
        bg = beautiful.colors.light_black_15,
        indicator = color.lighten(beautiful.colors.accent, 10),
        indicator_width = client.active and 22 or 4,
      })
    else
      container.animation:set_color({
        bg = beautiful.colors.light_background_10,
        indicator = beautiful.colors.light_background_10,
        indicator_width = client.active and 22 or 4,
      })
    end
  end)

  container:connect_signal("mouse::leave", function()
    if client.active then
      container.animation:set_color({
        bg = beautiful.colors.light_background_10,
        indicator = beautiful.colors.accent,
        indicator_width = client.active and 22 or 4,
      })
    else
      container.animation:set_color({
        bg = beautiful.colors.background,
        indicator = beautiful.colors.background,
        indicator_width = client.active and 22 or 4,
      })
    end
  end)

  container:add_button(utils:left_click(function()
    client:activate({
      context = "dock",
      raise = true,
      switch_to_tag = true,
    })
  end))

  return container
end

local function get_clients(self)
  local clients = {}

  for _, tag in ipairs(self.s.tags) do
    for _, client in ipairs(tag:clients()) do
      table.insert(clients, client)
    end
  end

  return clients
end

local function update_clients(self)
  local clients = get_clients(self)

  self.layout:reset()
  self.layout:add(Launcher(self))

  if #clients == 0 then
    return
  end

  for _, client in ipairs(clients) do
    self.layout:add(ClientButton(client))
  end
end

function tasklist:render()
  self.layout = wibox.layout.fixed.horizontal()
  self.layout.spacing = dpi(6)

  local function cb()
    gtimer.delayed_call(function()
      update_clients(self)
    end)
  end

  cb()

  Client.connect_signal("list", cb)
  Client.connect_signal("swapped", cb)
  Client.connect_signal("property::active", cb)
  Tag.connect_signal("property::selected", cb)

  return self.layout
end

return oop(tasklist)
