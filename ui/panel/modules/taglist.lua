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

local Face = require("framework.services.face")
local face = Face()

local taglist = {}

local function pfp()
  local container = wibox.widget({
    widget = wibox.container.background,
    border_width = dpi(1),
    border_color = beautiful.colors.light_background_10,
    shape = gshape.circle,
    {
      widget = wibox.widget.imagebox,
      image = face:fetch(),
      valign = "center",
      align = "center",
      forced_width = dpi(28),
      forced_height = dpi(28),
      clip_shape = gshape.circle,
    },
  })

  container.animation = animation:new({
    duration = 0.25,
    easing = animation.easing.inOutQuad,
    pos = color.hex_to_rgba(beautiful.colors.light_background_10),
    update = function(_, pos)
      container.border_color = color.rgba_to_hex(pos)
    end,
  })

  function container.animation:set_color(new_color)
    self:set({ target = color.hex_to_rgba(new_color) })
  end

  container:connect_signal("mouse::enter", function()
    container.animation:set_color(beautiful.colors.light_hovered_black_10)
  end)

  container:connect_signal("mouse::leave", function()
    container.animation:set_color(beautiful.colors.light_background_10)
  end)

  return container
end

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
        margins = utils:xmargins(4, 4, 8, 8),
        {
          widget = wibox.widget.textbox,
          id = "label-element",
          font = beautiful.fonts:choose("icons", 13),
          valign = "center",
          align = "center",
        },
      },
      create_callback = function(self, tag)
        local background = self:get_children_by_id("background-element")[1]
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
            foreground = color.hex_to_rgba(beautiful.colors.foreground),
          },
          update = function(_, pos)
            if pos.background then
              background.bg = color.rgba_to_hex(pos.background)
            end
            if pos.foreground then
              background.fg = color.rgba_to_hex(pos.foreground)
            end
          end,
        })

        local State = {
          ACTIVE = "Active",
          OCCUPIED = "Occupied",
          EMPTY = "Empty",
        }

        -- @default
        background.state = State.EMPTY

        function colors_anim:set_state(new_state)
          background.state = new_state.id

          self:set({
            background = color.hex_to_rgba(new_state.background),
            foreground = color.hex_to_rgba(new_state.foreground),
          })
        end

        background:connect_signal("mouse::enter", function()
          if background.state == State.ACTIVE then
            colors_anim:set_state({
              id = State.ACTIVE,
              background = color.lighten(beautiful.colors.accent, 45),
              foreground = beautiful.colors.background,
            })
          elseif background.state == State.OCCUPIED then
            colors_anim:set_state({
              id = State.OCCUPIED,
              background = beautiful.colors.light_background_7,
              foreground = beautiful.colors.accent,
            })
          else
            colors_anim:set_state({
              id = State.EMPTY,
              background = beautiful.colors.light_background_4,
              foreground = beautiful.colors.light_background_15,
            })
          end
        end)

        background:connect_signal("mouse::leave", function()
          if background.state == State.ACTIVE then
            colors_anim:set_state({
              id = State.ACTIVE,
              background = beautiful.colors.accent,
              foreground = beautiful.colors.background,
            })
          elseif background.state == State.OCCUPIED then
            colors_anim:set_state({
              id = State.OCCUPIED,
              background = beautiful.colors.background,
              foreground = beautiful.colors.accent,
            })
          else
            colors_anim:set_state({
              id = State.EMPTY,
              background = beautiful.colors.background,
              foreground = beautiful.colors.light_background_15,
            })
          end
        end)

        function self:update_colors()
          if tag.selected then
            colors_anim:set_state({
              id = State.ACTIVE,
              background = beautiful.colors.accent,
              foreground = beautiful.colors.background,
            })
          elseif #tag:clients() > 0 then
            colors_anim:set_state({
              id = State.OCCUPIED,
              background = beautiful.colors.background,
              foreground = beautiful.colors.accent,
            })
          else
            colors_anim:set_state({
              id = State.EMPTY,
              background = beautiful.colors.background,
              foreground = beautiful.colors.light_background_15,
            })
          end
        end

        function self:update_label()
          local icons = Configuration.GeneralBehavior:get_key("tag_icons")
          local num_tags = Configuration.GeneralBehavior:get_key("num_tags")

          if #icons ~= num_tags then
            print("warning: missing icons for tags!")
            print("assertion `#icons == num_tags` failed")
            print("filling missing icons with indexes instead")
          end

          label_element:set_markup_silently(
            tostring(icons[tag.index] or tag.index)
          )
        end

        function self:update()
          self:update_colors()
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
    margins = utils:xmargins(6, 6, 10, 10),
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(10),
      pfp(),
      mktaglist(self.s),
    },
  })
end

return oop(taglist)
