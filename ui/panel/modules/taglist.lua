local wibox = require("wibox")
local gtimer = require("gears.timer")
local gshape = require("gears.shape")
local awful = require("awful")
local hoverable = require("ui.guards.hoverable")
local animation = require("framework.animation")
local color = require("framework.color")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local icon_theme = require("framework.icon-theme")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local taglist = {}

local function launcher()
  local container = hoverable(wibox.widget({
    widget = wibox.container.background,
    fg = beautiful.colors.accent,
    bg = beautiful.colors.accent_shade,
    shape = utils:srounded(dpi(7)),
    {
      widget = wibox.container.margin,
      margins = utils:xmargins(4, 4, 7, 7),
      {
        widget = wibox.widget.textbox,
        font = beautiful.fonts:choose("icons", 12),
        markup = "",
      },
    },
  }))

  container:setup_hover({
    colors = {
      normal = beautiful.colors.accent_shade,
      hovered = beautiful.colors.light_accent_shade,
    },
  })

  -- TODO: Reveal custom launcher
  container:add_button(utils:left_click(function()
    print("hello world")
  end))

  return container
end

local function mktaglist(s)
  return awful.widget.taglist({
    screen = s,
    filter = function(t)
      return #t:clients() > 0 or t.selected
    end,
    layout = {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
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
              margins = utils:xmargins(0, 0, 6, 6),
              {
                widget = wibox.container.place,
                valign = "center",
                halign = "center",
                {
                  id = "clients-layout-element",
                  layout = wibox.layout.fixed.horizontal,
                  hexpand = true,
                  spacing = dpi(6),
                },
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
              bg = beautiful.colors.accent,
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
        local clients_layout =
          self:get_children_by_id("clients-layout-element")[1]

        background:add_button(utils:left_click(function()
          gtimer.delayed_call(function()
            tag:view_only()
          end)
        end))

        local colors_anim = animation:new({
          duration = 0.25,
          easing = animation.easing.inOutQuad,
          pos = {
            background = color.hex_to_rgba(beautiful.colors.accent_shade),
            indicator = color.hex_to_rgba(beautiful.colors.background),
            indicator_width = 15,
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

        function self:update_clients_layout()
          if not clients_layout then
            print(
              "[warning] cannot update clients layout in taglist for index "
                .. tag.index
            )
            return
          end

          local clients = utils:reverse(tag:clients())

          clients_layout:reset()

          if not clients or #clients == 0 then
            local numbers =
              { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" }
            return clients_layout:add(wibox.widget({
              widget = wibox.widget.textbox,
              markup = numbers[tag.index],
              valign = "center",
              align = "center",
            }))
          end

          for _, client in ipairs(clients) do
            clients_layout:add(wibox.widget({
              widget = wibox.widget.imagebox,
              valign = "center",
              halign = "center",
              forced_width = dpi(16),
              forced_height = dpi(16),
              image = icon_theme:get_client_icon_path(client),
            }))
          end
        end

        function self:update()
          if tag.selected then
            colors_anim:set_state({
              background = beautiful.colors.light_accent_shade,
              indicator_width = 25,
              indicator = beautiful.colors.accent,
            })
          else
            colors_anim:set_state({
              background = beautiful.colors.accent_shade,
              indicator_width = 15,
              indicator = beautiful.colors.light_accent_shade,
            })
          end

          self:update_clients_layout()
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
      launcher(),
      mktaglist(self.s),
    },
  })
end

return oop(taglist)
