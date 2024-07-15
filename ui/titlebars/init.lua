local wibox = require("wibox")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local awful = require("awful")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local animation = require("framework.animation")
local color = require("framework.color")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local _button = {}

function _button:constructor(base_color, c)
    self.color = base_color
    self.c = c
end

function _button:_apply_animation(btn)
    btn.color_animation = animation:new({
        duration = 0.25,
        easing = animation.easing.inOutQuad,
        pos = color.hex_to_rgba(self.color),
        update = function(_, pos)
            btn.bg = color.rgba_to_hex(pos)
        end,
    })

    function btn.color_animation:set_color(new_color)
        self:set({
            target = color.hex_to_rgba(new_color),
        })
    end
end

function _button:_create_widget()
    local btn = wibox.widget({
        widget = wibox.container.background,
        bg = self.color,
        shape = gshape.circle,
        forced_width = dpi(12),
        forced_height = dpi(12),
    })

    self:_apply_animation(btn)

    btn:connect_signal("mouse::enter", function(_)
        btn.color_animation:set_color(color.darken(self.color, 75))
    end)

    btn:connect_signal("mouse::leave", function(_)
        btn.color_animation:set_color(self.color)
    end)

    btn:add_button(awful.button({}, 1, function()
        self:emit_signal("click")
    end))

    self.c:connect_signal("property::active", function(_)
        if self.c.active then
            btn.color_animation:set_color(self.color)
        else
            btn.color_animation:set_color(beautiful.colors.black)
        end
    end)

    return btn
end

function _button:render()
    return self:_create_widget()
end

local Button = oop(_button)

Client.connect_signal("request::titlebars", function(c)
    if c.requests_no_titlebar then
        return
    end

    local titlebar = awful.titlebar(c, {
        position = "left",
        size = dpi(36),
        bg = beautiful.colors.transparent,
    })

    local buttons_layout = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        halign = "center",
        valign = "center",
    })

    local close_button = Button(beautiful.colors.red, c)
    local maximize_button = Button(beautiful.colors.yellow, c)
    local minimize_button = Button(beautiful.colors.green, c)

    close_button:connect_signal("click", function(_)
        c:kill()
    end)

    maximize_button:connect_signal("click", function(_)
        c.maximized = not c.maximized
    end)

    minimize_button:connect_signal("click", function(_)
        gtimer.delayed_call(function()
            c.minimized = not c.minimized
        end)
    end)

    for _, x in ipairs({ close_button, maximize_button, minimize_button }) do
        buttons_layout:add(x:render())
    end

    local widget = wibox.widget({
        widget = wibox.container.background,

        get_border = function(self)
            return self:get_children_by_id("border")[1]
        end,

        set_color = function(self, new_color)
            self.bg = new_color

            self.border.bg = utils:color_adaptive_shade(new_color, 5)
        end,

        {
            layout = wibox.layout.align.horizontal,
            nil,
            {
                widget = wibox.container.margin,
                top = dpi(10),
                buttons_layout,
            },
            {
                id = "border",
                widget = wibox.container.background,
                forced_width = 1,
            },
        },
    })

    local DEFAULT_COLOR = beautiful.colors.background

    widget.color = DEFAULT_COLOR

    widget.color_animation = animation:new({
        duration = 0.15,
        easing = animation.easing.inOutQuad,
        pos = color.hex_to_rgba(DEFAULT_COLOR),
        update = function(_, pos)
            widget.color = color.rgba_to_hex(pos)
        end,
    })

    function widget.color_animation:set_color(new_color)
        self:set({
            target = color.hex_to_rgba(new_color),
        })
    end

    c:connect_signal("property::active", function(_)
        widget.color_animation:set_color(
            beautiful.colors.background
            -- beautiful.colors[c.active and "light_background_1" or "background"]
        )
    end)

    -- wrapping in a wibox.container.background for a reason :D
    titlebar:setup({
        widget = wibox.container.background,
        widget,
    })
end)
