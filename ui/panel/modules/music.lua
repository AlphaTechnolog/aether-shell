local wibox = require('wibox')
local gshape = require('gears.shape')
local animation = require('framework.animation')
local utils = require('framework.utils')()
local oop = require('framework.oop')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local music = {}

function music:render()
  local content_layout = wibox.layout.fixed.horizontal()
  local chip_background = beautiful.colors:apply_shade('light_cyan_10')

  local container = wibox.widget({
    widget = wibox.container.background,
    bg = chip_background.bright,
    fg = beautiful.colors.cyan,
    shape = gshape.rounded_bar,
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(4, 4, 8, 7),
      content_layout,
    },
  })

  content_layout:add(wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.fonts:choose('icons', 12),
    markup = '',
    valign = 'center',
    align = 'center',
  }))

  local music = 'peaceful piano radio 🎹 - music to focus/study to'

  local expandible = wibox.widget({
    widget = wibox.container.margin,
    left = dpi(1),
    {
      id = 'background_element',
      widget = wibox.container.background,
      forced_width = dpi(1),
      visible = false,
      {
        widget = wibox.container.margin,
        left = dpi(2),
        {
          widget = wibox.container.scroll.horizontal,
          step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
          speed = 60,
          {
            widget = wibox.widget.textbox,
            text = music,
            align = 'center',
            valign = 'center',
          },
        },
      },
    },
  })

  expandible.background_element =
    expandible:get_children_by_id('background_element')[1]

  local ExpandibleStatus = {
    Opening = 'Opening',
    Closing = 'Closing',
    Idle = 'Idle',
  }

  expandible.animation = animation:new({
    duration = 0.75,
    easing = animation.easing.inOutExpo,
    pos = 1,
    update = function(_, pos)
      expandible.background_element.forced_width = dpi(pos)
    end,
    signals = {
      ['ended'] = function()
        if expandible.status == ExpandibleStatus.Closing then
          expandible.background_element.visible = false
        end
        expandible.status = ExpandibleStatus.Idle
      end,
    },
  })

  expandible.status = ExpandibleStatus.Idle

  function expandible.animation:reveal()
    expandible.status = ExpandibleStatus.Opening
    expandible.background_element.visible = true

    self:set((#music < 40 and #music or 40) * 6)
  end

  function expandible.animation:hide()
    expandible.status = ExpandibleStatus.Closing
    self:set(1)
  end

  container:connect_signal('mouse::enter', function()
    expandible.animation:reveal()
  end)

  container:connect_signal('mouse::leave', function()
    expandible.animation:hide()
  end)

  content_layout:add(expandible)

  return wibox.widget({
    widget = wibox.container.margin,
    margins = dpi(7),
    container,
  })
end

return oop(music)
