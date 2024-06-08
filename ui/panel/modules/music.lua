local wibox = require("wibox")
local gshape = require("gears.shape")
local bling = require("extern.bling")
local animation = require("framework.animation")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local music = {}

function music:render()
  local content_layout = wibox.layout.fixed.horizontal()
  local chip_background = beautiful.colors:apply_shade("secondary_accent")
  local playerctl = bling.signal.playerctl.lib()

  local container = wibox.widget({
    widget = wibox.container.background,
    bg = chip_background.bright,
    fg = beautiful.colors.secondary_accent,
    shape = gshape.rounded_bar,
    visible = false,
    opacity = 0,
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(4, 4, 7, 8),
      content_layout,
    },
  })

  local CONTAINER_STATUSES = {
    Opening = "Opening",
    Closing = "Closing",
    Idle = "Idle",
  }

  container.status = CONTAINER_STATUSES.Idle

  container.opacity_animation = animation:new({
    duration = 0.25,
    easing = animation.easing.linear,
    pos = 0,
    update = function(_, pos)
      container.opacity = pos
    end,
    signals = {
      ["ended"] = function(_)
        if container.status == CONTAINER_STATUSES.Closing then
          container.visible = false
        end
        container.status = CONTAINER_STATUSES.Idle
      end,
    },
  })

  function container:hide()
    container.status = CONTAINER_STATUSES.Closing
    self.opacity_animation:set(0)
  end

  function container:show()
    container.status = CONTAINER_STATUSES.Opening
    container.visible = true
    self.opacity_animation:set(1)
  end

  self.raw_music_name = ""

  local music_name = wibox.widget({
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  playerctl:connect_signal("metadata", function(_, title)
    music_name:set_markup_silently(title)
    container:show()
    self.raw_music_name = title
  end)

  playerctl:connect_signal("no_players", function()
    music_name:set_markup_silently("")
    container:hide()
    self.raw_music_name = ""
  end)

  local expandible = wibox.widget({
    widget = wibox.container.margin,
    right = dpi(1),
    {
      id = "background_element",
      widget = wibox.container.background,
      forced_width = dpi(1),
      visible = false,
      {
        widget = wibox.container.margin,
        right = dpi(2),
        {
          widget = wibox.container.scroll.horizontal,
          step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
          speed = 60,
          music_name,
        },
      },
    },
  })

  expandible.background_element =
    expandible:get_children_by_id("background_element")[1]

  local ExpandibleStatus = {
    Opening = "Opening",
    Closing = "Closing",
    Idle = "Idle",
  }

  expandible.animation = animation:new({
    duration = 0.75,
    easing = animation.easing.inOutExpo,
    pos = 1,
    update = function(_, pos)
      expandible.background_element.forced_width = dpi(pos)
    end,
    signals = {
      ["ended"] = function()
        if expandible.status == ExpandibleStatus.Closing then
          expandible.background_element.visible = false
        end
        expandible.status = ExpandibleStatus.Idle
      end,
    },
  })

  expandible.status = ExpandibleStatus.Idle

  local cself = self

  function expandible.animation:reveal()
    expandible.status = ExpandibleStatus.Opening
    expandible.background_element.visible = true
    self:set((#cself.raw_music_name < 40 and #cself.raw_music_name or 40) * 6)
  end

  function expandible.animation:hide()
    expandible.status = ExpandibleStatus.Closing
    self:set(1)
  end

  container:connect_signal("mouse::enter", function()
    expandible.animation:reveal()
  end)

  container:connect_signal("mouse::leave", function()
    expandible.animation:hide()
  end)

  content_layout:add(expandible)

  content_layout:add(wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.fonts:choose("icons", 12),
    markup = "",
    valign = "center",
    align = "center",
  }))

  return container
end

return oop(music)
