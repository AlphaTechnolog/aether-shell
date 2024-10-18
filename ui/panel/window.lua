local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local oop = require("framework.oop")

local Launcher = require("ui.panel.components.launcher")
local Workspaces = require("ui.panel.components.workspaces")

local Window = {
    _priv = { s = nil, popup = nil, },
}

function Window:constructor(s)
    self._priv.s = s
    self:make_window()
end

function Window:make_window()
    local s = self._priv.s

    -- satisfy lua-lsp
    if not s or not s.geometry then
        return
    end

    local height = dpi(40)

    local popup = awful.popup({
        screen = self._priv.s,
        minimum_width = s.geometry.width,
        minimum_height = height,
        maximum_width = s.geometry.width,
        maximum_height = height,
        x = s.geometry.x,
        y = s.geometry.y,
        bg = beautiful.colors.background,
        fg = beautiful.colors.foreground,
        visible = false,
        widget = {
            layout = wibox.layout.align.vertical,
            nil,
            {
                widget = wibox.container.background,
                bg = beautiful.colors.background,
                fg = beautiful.colors.foreground,
                {
                    widget = wibox.container.margin,
                    margins = dpi(4),
                    {
                        layout = wibox.layout.align.horizontal,
                        {
                            widget = wibox.container.margin,
                            right = dpi(4),
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = dpi(4),
                                Launcher():render(),
                            }
                        },
                        Workspaces(self._priv.s):render(),
                    }
                }
            },
            {
                widget = wibox.container.background,
                bg = beautiful.colors.light_background_2,
                forced_height = dpi(2),
            }
        }
    })

    function popup:show()
        self.visible = true
    end

    function popup:hide()
        self.visible = false
    end

    popup:struts {
        top = height,
    }

    self._priv.popup = popup
end

function Window:raise()
    local popup = self._priv.popup

    if not popup then
        return
    end

    if not popup.visible then
        popup:show()
    end
end

return oop(Window)