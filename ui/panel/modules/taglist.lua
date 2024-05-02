local wibox = require("wibox")
local gtimer = require("gears.timer")
local gshape = require("gears.shape")
local awful = require("awful")
local hoverable = require("ui.guards.hoverable")
local animation = require("framework.animation")
local color = require("framework.color")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local taglist = {}

local function launcher()
  local container = hoverable(wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.white,
    fg = beautiful.colors.black,
    shape = utils:srounded(dpi(7)),
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(4, 4, 6, 6),
      {
        widget = wibox.widget.textbox,
        font = beautiful.fonts:choose("icons", 12),
        markup = ""
      }
    }
  }))

  container:setup_hover({
    colors = {
      normal = beautiful.colors.white,
      hovered = color.darken(beautiful.colors.white, 64),
    }
  })

  -- TODO: Reveal custom launcher
  container:add_button(utils:left_click(function ()
    print("hello world")
  end))

  return container
end

local function mktaglist(s)
  return awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(6)
    },
    widget_template = {
      id = "background-element",
      widget = wibox.container.background,
      shape = utils:srounded(dpi(7)),
      {
        widget = wibox.container.margin,
        margins = utils:xmargins(0, 2, 6, 6),
        {
          layout = wibox.layout.align.vertical,
          nil,
          {
            widget = wibox.container.background,
            {
              widget = wibox.container.margin,
              margins = utils:xmargins(0, 0, 4, 4),
              {
                id = "text-element",
                widget = wibox.widget.textbox,
                halign = "center",
                valign = "center",
              }
            }
          },
          {
            id = "indicator-element",
            widget = wibox.container.background,
            bg = beautiful.colors.blue,
            shape = gshape.rounded_bar,
            forced_height = 3,
            forced_width = 16,
          }
        },
      },
      create_callback = function (self, tag)
        local background = self:get_children_by_id("background-element")[1]
        local text = self:get_children_by_id("text-element")[1]
        local indicator = self:get_children_by_id("indicator-element")[1]

        local colors_anim = animation:new {
          duration = 0.25,
          easing = animation.easing.inOutQuad,
          pos = {
            background = color.hex_to_rgba(beautiful.colors.background),
            indicator = color.hex_to_rgba(beautiful.colors.background),
          },
          update = function (_, pos)
            if pos.background then
              background.bg = color.rgba_to_hex(pos.background)
            end
            if pos.indicator then
              indicator.bg = color.rgba_to_hex(pos.indicator)
            end
          end
        }

        function colors_anim:set_state(new_state)
          self:set({
            background = color.hex_to_rgba(new_state.background),
            indicator = color.hex_to_rgba(new_state.indicator),
          })
        end

        function self:update()
          if tag.selected or #tag:clients() > 0 then
            colors_anim:set_state({
              background = color.lighten(beautiful.colors.background),
              indicator = tag.selected
                and beautiful.colors.blue
                or color.lighten(beautiful.colors.background, 60)
            })
          else
            colors_anim:set_state({
              background = color.lighten(beautiful.colors.background, 12),
              indicator = color.lighten(beautiful.colors.background, 25)
            })
          end

          local roman_numbers = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"}
          text:set_markup_silently(tostring(roman_numbers[tag.index]))
        end

        gtimer.delayed_call(function ()
          self:update()
        end)
      end,
      update_callback = function (self)
        if self.update ~= nil then
          gtimer.delayed_call(function ()
            self:update()
          end)
        end
      end
    }
  }
end

function taglist:constructor(s)
  self.s = s
end

function taglist:render()
  return wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    shape = utils:srounded(dpi(7)),
    {
      widget = wibox.container.margin,
      margins = dpi(6),
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(6),
        launcher(),
        mktaglist(self.s),
      }
    }
  })
end

return oop(taglist)