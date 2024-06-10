local wibox = require("wibox")
local gtimer = require("gears.timer")
local animation = require("framework.animation")
local icon_theme = require("framework.icon-theme")()
local utils = require("framework.utils")()
local hoverable = require("ui.guards.hoverable")
local gshape = require("gears.shape")
local naughty = require("naughty");
local beautiful = require("beautiful");
local dpi = beautiful.xresources.apply_dpi

local function create_notification(n)
  n:set_timeout(999999)

  local app_icon = wibox.widget({
    widget = wibox.widget.imagebox,
    halign = "center",
    valign = "center",
    forced_width = dpi(24),
    forced_height = dpi(24),
    clip_shape = utils:srounded(dpi(10)),
    image = n.app_icon
  })

  local icon = wibox.widget({
    widget = wibox.widget.imagebox,
    forced_width = dpi(48),
    forced_height = dpi(48),
    halign = "center",
    valign = "center",
    clip_shape = utils:srounded(dpi(12)),
    image = n.icon,
  })

  local app_name = wibox.widget({
    widget = wibox.widget.textbox,
    markup = utils:capitalize(n.app_name or "Unknown"),
    valign = "center",
    align = "center",
  })

  local dismiss = hoverable(wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.colors.background,
    fg = beautiful.colors.accent,
    shape = gshape.circle,
    {
      widget = wibox.widget.textbox,
      markup = "",
      font = beautiful.fonts:choose("icons", 12),
      valign = "center",
      align = "center",
    }
  }))

  dismiss:setup_hover({
    colors = {
      normal = beautiful.colors.background,
      hovered = beautiful.colors.light_background_10
    }
  })

  dismiss:add_button(utils:left_click(function ()
    n:destroy(naughty.notification_closed_reason.dismissed_by_user)
  end))

  local close_button = wibox.widget({
    widget = wibox.container.arcchart,
    forced_width = dpi(24),
    forced_height = dpi(24),
    max_value = 100,
    min_value = 0,
    value = 0,
    thickness = dpi(3),
    rounded_edge = true,
    bg = beautiful.colors.light_background_12,
    colors = { beautiful.colors.accent },
    dismiss
  })

  local close_button_timeout_animation = animation:new({
    target = 100,
    duration = 5,
    easing = animation.easing.linear,
    reset_on_stop = false,
    pos = 0,
    update = function (_, pos)
      close_button.value = pos
    end
  })

  local title = utils:scrollable(wibox.widget({
    widget = wibox.widget.textbox,
    visible = n.title ~= nil and n.title ~= "",
    font = beautiful.fonts:choose("normal", 16),
    valign = "center",
    align = "left",
    markup = utils:build_markup({
      bold = true,
      markup = n.title
    }),
  }))

  local body = utils:scrollable(wibox.widget({
    widget = wibox.widget.textbox,
    visible = n.text ~= nil and n.text ~= "",
    markup = n.text,
    valign = "center",
    align = "left",
  }))

  local actions = wibox.widget({
    layout = wibox.layout.flex.horizontal,
    spacing = dpi(7),
  })

  for _, action in ipairs(n.actions) do
    local button = hoverable(wibox.widget({
      widget = wibox.container.background,
      bg = beautiful.colors.light_background_7,
      shape = utils:srounded(dpi(7)),
      border_width = dpi(1),
      border_color = beautiful.colors.light_background_15,
      {
        widget = wibox.container.margin,
        margins = utils:xmargins(6, 6, 10, 10),
        {
          widget = wibox.widget.textbox,
          markup = action.name,
          valign = "center",
          align = "center",
        }
      }
    }))

    button:setup_hover({
      colors = {
        normal = beautiful.colors.light_background_7,
        hovered = beautiful.colors.light_background_12
      }
    })

    button:add_button(utils:left_click(function ()
      gtimer.delayed_call(function ()
        action:invoke()
      end)
    end))

    actions:add(button)
  end

  local notif_widget = naughty.layout.box({
    notification = n,
    type = "notification",
    shape = gshape.rectangle,
    bg = beautiful.colors.transparent,
    minimum_width = dpi(360),
    minimum_height = dpi(60),
    maximum_width = dpi(360),
    maximum_height = dpi(300),

    widget_template = {
      widget = wibox.container.background,
      bg = beautiful.colors.transparent,
      {
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        border_width = dpi(1),
        border_color = beautiful.colors.light_background_12,
        shape = utils:srounded(dpi(6)),
        {
          layout = wibox.layout.align.vertical,
          {
            layout = wibox.layout.align.vertical,
            nil,
            {
              widget = wibox.container.margin,
              margins = utils:xmargins(8, 8, 10, 10),
              {
                widget = wibox.layout.align.horizontal,
                {
                  layout = wibox.layout.fixed.horizontal,
                  spacing = dpi(4),
                  app_icon,
                  app_name,
                },
                nil,
                {
                  widget = wibox.container.margin,
                  left = dpi(10),
                  close_button
                }
              }
            },
            {
              widget = wibox.container.background,
              bg = beautiful.colors.light_background_12,
              forced_height = dpi(1),
            }
          },
          {
            widget = wibox.container.margin,
            margins = dpi(12),
            {
              layout = wibox.layout.align.horizontal,
              icon,
              {
                widget = wibox.container.margin,
                left = dpi(10),
                {
                  widget = wibox.layout.align.vertical,
                  nil,
                  {
                    widget = wibox.container.place,
                    valign = "center",
                    halign = "left",
                    {
                      layout = wibox.layout.fixed.vertical,
                      spacing = dpi(2),
                      title,
                      body
                    }
                  },
                  {
                    widget = wibox.container.margin,
                    top = dpi(12),
                    actions,
                  },
                }
              }
            }
          }
        },
      }
    },
  })

  -- Don't destroy the notification on click
  notif_widget.buttons = {}

  notif_widget:connect_signal("mouse::enter", function ()
    close_button_timeout_animation:stop()
  end)

  notif_widget:connect_signal("mouse::leave", function ()
    close_button_timeout_animation:set()
  end)

  close_button_timeout_animation:connect_signal("ended", function ()
    n:destroy()
  end)

  gtimer.delayed_call(function ()
    close_button_timeout_animation:set()
  end)
end

naughty.connect_signal("added", function(n)
  if n.title == "" or n.title == nil then
    n.title = n.app_name
  end

  if type(n._private.app_icon) == "table" then
    n.app_icon = icon_theme:choose_icon(n._private.app_icon)
  else
    n.app_icon = icon_theme:get_icon_path(n._private.app_icon or n.app_name)
  end

  if type(n.icon) == "table" then
    n.icon = icon_theme:choose_icon(n.icon)
  end

  if n.app_icon == "" or n.app_icon == nil then
    n.app_icon = icon_theme:get_icon_path "application-default-icon"
  end

  if n.icon == "" or n.icon == nil then
    n.icon = icon_theme:get_icon_path "preferences-desktop-notification-bell"
  end
end)

naughty.connect_signal("request::display", function (n)
  gtimer.start_new(0.1, function ()
    if #naughty.active > 3 then
      return true
    end

    create_notification(n)
    return false
  end)
end)
