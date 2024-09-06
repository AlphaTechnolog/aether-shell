local wibox = require("wibox")
local awful = require("awful")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local animation = require("framework.animation")
local color = require("framework.color")
local oop = require("framework.oop")
local utils = require("framework.utils")()

local Taglist = {
    s = nil
}

function Taglist:constructor(s)
    self.s = s
end

local function required_obtain(self, key)
    local value = self[key]
    if not value then
        error("unable to obtain required key " .. key)
    end

    return value
end

function Taglist:_generate_taglist()
    local s = required_obtain(self, "s")

    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(8),
        },
        widget_template = {
            widget = wibox.container.place,
            valign = "center",
            halign = "center",
            ---@diagnostic disable-next-line: redefined-local
            create_callback = function (self, tag)
                local States = {
                    ACTIVE = 1,
                    OCCUPIED = 2,
                    INACTIVE = 3
                }

                local Colors = {
                    [States.ACTIVE] = beautiful.colors.accent,
                    [States.OCCUPIED] = beautiful.colors.light_hovered_black_15,
                    [States.INACTIVE] = beautiful.colors.hovered_black,
                }

                -- just in case in future someone wants to enable resizing based on states.
                local Sizes = {
                    [States.ACTIVE] = dpi(12),
                    [States.OCCUPIED] = dpi(12),
                    [States.INACTIVE] = dpi(12),
                }

                function Colors:with_state(state)
                    return self[state] or self[States.INACTIVE]
                end

                function Sizes:with_state(state)
                    return self[state] or self[States.INACTIVE]
                end

                self.general_animation = animation:new({
                    duration = 0.3,
                    easing = animation.easing.inOutCubic,
                    pos = {
                        color = color.hex_to_rgba(Colors:with_state(States.INACTIVE)),
                        size = Sizes:with_state(States.INACTIVE),
                    },
                    update = function (_, pos)
                        if pos.color ~= nil then
                            self.background_element.bg = color.rgba_to_hex(pos.color)
                        end
                        if pos.size ~= nil then
                            self.background_element.forced_width = pos.size
                        end
                    end
                })

                function self.general_animation:update(elements)
                    if elements.color ~= nil then
                        elements.color = color.hex_to_rgba(elements.color)
                    end

                    self:set(elements)
                end

                function self:update()
                    if tag.selected then
                        self.general_animation:update({
                            color = Colors:with_state(States.ACTIVE),
                            size = Sizes:with_state(States.ACTIVE)
                        })
                    elseif #tag:clients() > 0 then
                        self.general_animation:update({
                            color = Colors:with_state(States.OCCUPIED),
                            size = Sizes:with_state(States.OCCUPIED)
                        })
                    else
                        self.general_animation:update({
                            color = Colors:with_state(States.INACTIVE),
                            size = Sizes:with_state(States.INACTIVE)
                        })
                    end
                end

                utils:delayed(function ()
                    self:update()
                end)

                self.background_element:add_button(utils:left_click(function ()
                    utils:delayed(function ()
                        tag:view_only()
                    end)
                end))
            end,
            ---@diagnostic disable-next-line: redefined-local
            update_callback = function (self)
                if self.update ~= nil then
                    utils:delayed(function ()
                        self:update()
                    end)
                end
            end,
            {
                id = "background_element",
                widget = wibox.container.background,
                shape = gshape.rounded_bar,
                forced_width = dpi(12),
                forced_height = dpi(12),
                valign = "center",
                halign = "center",
                bg = beautiful.colors.hovered_black,
            },
        }
    }
end

function Taglist:render()
    return wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.light_background_4,
        shape = gshape.rounded_bar,
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(4, 4, 12, 12),
            self:_generate_taglist()
        },
    })
end

return oop(Taglist)
