local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("framework.utils")()
local icon_theme = require("framework.icon-theme")()
local hoverable = require("ui.guards.hoverable")
local oop = require("framework.oop")

local Titlebars = {
    _priv = { c = nil, },
}

function Titlebars:constructor(c)
    self._priv.c = c
end

function Titlebars:close_button()
    local c = self._priv.c

    if not c then
        return
    end

    local button = hoverable(wibox.widget({
        widget = wibox.container.background,
        {
            widget = wibox.container.margin,
            margins = dpi(2),
            {
                widget = wibox.widget.textbox,
                markup = "",
                font = beautiful.fonts:choose("icons", 12),
                valign = "center",
                align = "center",
            }
        }
    }))

    button:setup_hover({
        colors = {
            normal = beautiful.colors.light_background_1,
            hovered = beautiful.colors.light_background_5,
        }
    })

    button:add_button(utils:left_click(function ()
        c:kill()
    end))

    return button
end

function Titlebars:render()
    local c = self._priv.c

    if not c then
        return
    end

    return {
        layout = wibox.layout.align.vertical,
        nil,
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(4, 4, 8, 8),
            {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    {
                        widget = wibox.widget.imagebox,
                        image = icon_theme:get_client_icon_path(c),
                        valign = "center",
                        halign = "center",
                        forced_width = dpi(18),
                        forced_height = dpi(18),
                    },
                    {
                        id = "name_element",
                        widget = wibox.widget.textbox,
                        markup = c.name,
                        align = "center",
                        valign = "center",
                    }
                },
                nil,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(4),
                    self:close_button(),
                }
            }
        },
        {
            id = "border_element",
            widget = wibox.container.background,
            bg = beautiful.colors.light_background_5,
            forced_height = dpi(2),
        }
    }
end

return oop(Titlebars)