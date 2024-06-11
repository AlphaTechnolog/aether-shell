local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local hoverable = require("ui.guards.hoverable")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local animation = require("framework.animation")
local color = require("framework.color")
local icon_theme = require("framework.icon-theme")()
local dpi = beautiful.xresources.apply_dpi

local Tasklist = {}

local SearchServiceBar = require("ui.panel.modules.search_service_bar")

function Tasklist:constructor(s)
  self.s = s
  self.search_bar = SearchServiceBar(self.s)
end

local function Launcher()
  local container = hoverable(wibox.widget({
    widget = wibox.container.background,
    shape = gshape.squircle,
    bg = beautiful.colors.background,
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(5, 5, 6, 6),
      {
        widget = wibox.widget.imagebox,
        image = beautiful.distro,
        valign = "center",
        halign = "center",
        forced_width = dpi(20),
        forced_height = dpi(20),

        -- circled for awesomewm icon idk
        clip_shape = (
          beautiful:non_supported_distro_icon() and gshape.circle
          or nil
        ),
      },
    },
  }))

  container:setup_hover({
    colors = {
      normal = beautiful.colors.background,
      hovered = beautiful.colors.light_background_5,
    },
  })

  container:add_button(awful.button({}, 1, function()
    require("naughty").notify({ title = "todo" })
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

local function ClientButton(client)
  local container = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    shape = gshape.squircle,
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(5, 5, 6, 6),
      {
        widget = wibox.widget.imagebox,
        image = icon_theme:get_client_icon_path(client),
        valign = "center",
        halign = "center",
        forced_width = dpi(20),
        forced_height = dpi(20),
      }
    }
  })

  container.animation = animation:new({
    duration = 0.25,
    easing = animation.easing.inOutQuad,
    pos = color.hex_to_rgba(beautiful.colors.background),
    update = function (_, pos)
      container.bg = color.rgba_to_hex(pos)
    end
  })

  function container.animation:set_color(new_color)
    self:set({ target = color.hex_to_rgba(new_color) })
  end

  local ContainerStatus = {
    EXPANDED = "Expanded",
    IDLE = "Idle"
  }

  container.status = ContainerStatus.IDLE

  container:connect_signal("mouse::enter", function ()
    if container.status == ContainerStatus.IDLE then
      container.animation:set_color(beautiful.colors.light_background_8)
    elseif container.status == ContainerStatus.EXPANDED then
      container.animation:set_color(beautiful.colors.light_background_14)
    end
  end)

  local function update_container_background()
    if container.status == ContainerStatus.IDLE then
      container.animation:set_color(beautiful.colors.background)
    elseif container.status == ContainerStatus.EXPANDED then
      container.animation:set_color(beautiful.colors.light_background_8)
    end
  end

  function container:change_status(new_status)
    self.status = new_status
    update_container_background()
  end

  container:connect_signal("mouse::leave", function ()
    update_container_background()
  end)

  local function subscribed(key, callback)
    local function set_value()
      gtimer.delayed_call(function ()
        if callback ~= nil then
          callback()
        end
      end)
    end

    set_value()

    client:connect_signal("property::" .. key, set_value)
  end

  subscribed("active", function ()
    if client.active then
      container:change_status(ContainerStatus.EXPANDED)
    else
      container:change_status(ContainerStatus.IDLE)
    end
  end)

  container:add_button(utils:left_click(function ()
    client:activate({
      context = "dock",
      raise = true,
      switch_to_tag = true,
    })
  end))

  return container
end

local function update_clients(self)
  local clients = get_clients(self)

  self.content_layout:reinit()

  if #clients == 0 then
    return
  end

  for _, client in ipairs(clients) do
    self.content_layout:add(ClientButton(client))
  end
end

function Tasklist:render()
  self.content_layout = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(6),
  })

  local gself = self

  function self.content_layout:reinit()
    self:reset()
    self:add(Launcher())
    self:add(gself.search_bar:render())
  end

  self.content_layout:reinit()

  local delayed_clients_update = function ()
    gtimer.delayed_call(function ()
      update_clients(self)
    end)
  end

  delayed_clients_update()

  -- Subscribing to clients/windows events to update the dock
  Client.connect_signal("list", delayed_clients_update)
  Client.connect_signal("swapped", delayed_clients_update)
  Client.connect_signal("property::active", delayed_clients_update)
  Tag.connect_signal("property::selected", delayed_clients_update)

  return wibox.widget({
    widget = wibox.container.margin,
    margins = utils:xmargins(2, 2, 0, 0),
    self.content_layout,
  })
end

return oop(Tasklist)
