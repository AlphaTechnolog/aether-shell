local wibox = require("wibox")
local gtimer = require("gears.timer")
local gshape = require("gears.shape")
local awful = require("awful")
local animation = require("framework.animation")
local color = require("framework.color")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local taglist = {}

local function mktaglist(s)
  return awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
    },
    widget_template = {
      id = "background-element",
      widget = wibox.container.background,
      shape = gshape.squircle,
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
              -- fixed margin so no weird behavior when expanding the indicator happens :)
              margins = utils:xmargins(0, 0, 7, 7),
              {
                widget = wibox.container.place,
                valign = "center",
                halign = "center",
                {
                  id = 'label-element',
                  widget = wibox.widget.textbox,
                  valign = 'center',
                  align = 'center',
                }
              },
            },
          },
          {
            widget = wibox.container.place,
            valign = "center",
            halign = "center",
            {
              id = "indicator-element",
              widget = wibox.container.background,
              bg = beautiful.colors.light_background_15,
              shape = gshape.rounded_bar,
              forced_height = dpi(3),
              forced_width = dpi(15),
            },
          },
        },
      },
      create_callback = function(self, tag)
        local background = self:get_children_by_id("background-element")[1]
        local indicator = self:get_children_by_id("indicator-element")[1]
        local label_element = self:get_children_by_id("label-element")[1]

        background:add_button(utils:left_click(function()
          gtimer.delayed_call(function()
            tag:view_only()
          end)
        end))

        local colors_anim = animation:new({
          duration = 0.25,
          easing = animation.easing.inOutQuad,
          pos = {
            background = color.hex_to_rgba(beautiful.colors.light_background_3),
            indicator = color.hex_to_rgba(beautiful.colors.light_background_15),
            indicator_width = 6,
          },
          update = function(_, pos)
            if pos.background then
              background.bg = color.rgba_to_hex(pos.background)
            end
            if pos.indicator then
              indicator.bg = color.rgba_to_hex(pos.indicator)
            end
            if pos.indicator_width then
              indicator.forced_width = dpi(pos.indicator_width)
            end
          end,
        })

        function colors_anim:set_state(new_state)
          self:set({
            background = color.hex_to_rgba(new_state.background),
            indicator = color.hex_to_rgba(new_state.indicator),
            indicator_width = new_state.indicator_width,
          })
        end

        function self:update_label()
          label_element:set_markup_silently(tostring(tag.index))
        end

        function self:update()
          if tag.selected then
            colors_anim:set_state({
              background = beautiful.colors.light_background_12,
              indicator_width = 15,
              indicator = beautiful.colors.accent,
            })
          elseif #tag:clients() > 0 then
            colors_anim:set_state({
              background = beautiful.colors.light_background_6,
              indicator_width = 10,
              indicator = beautiful.colors.light_hovered_black_10,
            })
          else
            colors_anim:set_state({
              background = beautiful.colors.light_background_3,
              indicator_width = 6,
              indicator = beautiful.colors.light_background_15,
            })
          end

          self:update_label()
        end

        gtimer.delayed_call(function()
          self:update()
        end)
      end,
      update_callback = function(self)
        if self.update ~= nil then
          gtimer.delayed_call(function()
            self:update()
          end)
        end
      end,
    },
  })
end

function taglist:constructor(s)
  self.s = s
end

function taglist:render()
  return wibox.widget({
    widget = wibox.container.margin,
    margins = dpi(6),
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
      mktaglist(self.s),
    },
  })
end

return oop(taglist)
