local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local animation = require("framework.animation")
local color = require("framework.color")
local utils = require("framework.utils")()
local oop = require("framework.oop")

local Workspaces = {
    _priv = { s = nil, colors = {} }
}

function Workspaces:constructor(s)
    self._priv.s = s

    self._priv.colors = {
        inactive = beautiful.colors.light_background_1,
        active = beautiful.colors.black,
        occupied = beautiful.colors.light_background_3
    }
end

function Workspaces:render()
    local colors = self._priv.colors

    return awful.widget.taglist {
        screen = self._priv.s,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.flex.horizontal,
        },
        widget_template = {
            widget = wibox.container.background,
            bg = self._priv.colors.inactive,
            create_callback = function (self, tag)
                local background_animation = animation:new({
                    duration = 0.15,
                    easing = animation.easing.inOutQuad,
                    pos = color.hex_to_rgba(colors.inactive),
                    update = function (_, pos)
                        self.bg = color.rgba_to_hex(pos)
                    end,
                })

                function self:set_color(newcolor)
                    background_animation:set({
                        target = color.hex_to_rgba(colors[newcolor])
                    })
                end

                function self:update_label()
                    local content_label = self.content_label
                    local tag_labels = Configuration.GeneralBehavior:get_key("tag_labels")
                    local label = tag_labels[tag.index]
                    content_label:set_markup_silently(label:upper())
                end

                function self:update()
                    if tag.selected then
                        self:set_color("active")
                    elseif #tag:clients() > 0 then
                        self:set_color("occupied")
                    else
                        self:set_color("inactive")
                    end

                    self:update_label()
                end

                gtimer.delayed_call(function ()
                    self:update()
                end)

                self:add_button(utils:left_click(function ()
                    gtimer.delayed_call(function ()
                        tag:view_only()
                    end)
                end))
            end,
            update_callback = function (self)
                if self.update ~= nil then
                    gtimer.delayed_call(function ()
                        self:update()
                    end)
                end
            end,
            {
                id = "content_label",
                widget = wibox.widget.textbox,
                markup = "hello",
                valign = "center",
                align = "center",
            },
        }
    }
end

return oop(Workspaces)