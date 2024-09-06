local wibox = require("wibox")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local icon_theme = require("framework.icon-theme")()
local utils = require("framework.utils")()
local oop = require("framework.oop")
local color = require("framework.color")
local animation = require("framework.animation")

local capi = {
    tag = tag,
    client = client,
}

local Taglist = {}

function Taglist:constructor(s)
    self.s = s
    self.content_layout = wibox.layout.fixed.horizontal()
    self.content_layout.spacing = dpi(4)
end

function WorkspaceItem(tag)
    local clients_layout = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(4),
    })

    local main_layout = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(4),
    })

    local label = wibox.widget({
        widget = wibox.widget.textbox,
        markup = tostring(tag.index),
        valign = "center",
        align = "center",
    })

    local function selected_color(selected, normal)
        return tag.selected and selected or normal
    end

    local function get_chip_color()
        return selected_color(
            beautiful.colors.light_background_10,
            beautiful.colors.light_background_4
        )
    end

    local function get_separator_color()
        return selected_color(
            beautiful.colors.light_hovered_black_15,
            beautiful.colors.light_background_15
        )
    end

    local chip_color = get_chip_color()
    local separator_color = get_separator_color()

    local separator = wibox.widget({
        widget = wibox.container.margin,
        margins = {
            left = dpi(4),
            right = dpi(4),
        },
        {
            id = "background_element",
            widget = wibox.container.background,
            bg = separator_color,
            forced_width = dpi(1),
            vexpand = true,
        }
    })

    local function update_clients()
        clients_layout:reset()

        for _, c in ipairs(tag:clients()) do
            clients_layout:add(wibox.widget({
                widget = wibox.widget.imagebox,
                forced_width = dpi(16),
                forced_height = dpi(16),
                valign = "center",
                align = "center",
                image = icon_theme:get_client_icon_path(c) or c.icon,
            }))
        end

        main_layout:reset()

        local has_clients = #tag:clients() > 0

        if has_clients then
            main_layout:add(clients_layout)
            main_layout:add(separator)
        end

        main_layout:add(label)
    end

    local function lazy_clients_update()
        gtimer.delayed_call(function ()
            update_clients()
        end)
    end

    lazy_clients_update()

    capi.client.connect_signal("list", lazy_clients_update)
    capi.client.connect_signal("tagged", lazy_clients_update)

    local chip = wibox.widget({
        widget = wibox.container.background,
        bg = chip_color,
        shape = utils:srounded(dpi(7)),
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(10),
                right = dpi(10),
                top = dpi(4),
                bottom = dpi(4),
            },
            main_layout,
        }
    })

    chip.animation = animation:new({
        duration = 0.25,
        easing = animation.easing.inOutQuad,
        pos = color.hex_to_rgba(chip_color),
        update = function(_, pos)
            chip.bg = color.rgba_to_hex(pos)
        end,
    })

    function chip.animation:set_color(new_color)
        self:set({ target = color.hex_to_rgba(new_color) })
    end

    tag:connect_signal("property::selected", function (_)
        chip_color = get_chip_color()
        separator_color = get_separator_color()
        chip.animation:set_color(chip_color)
        separator.background_element.bg = separator_color
    end)

    chip:connect_signal("mouse::enter", function ()
        chip.animation:set_color(color.lighten(chip_color, 15))
    end)

    chip:connect_signal("mouse::leave", function ()
        chip.animation:set_color(chip_color)
    end)

    chip:add_button(utils:left_click(function ()
        gtimer.delayed_call(function ()
            tag:view_only()
        end)
    end))

    return chip
end

function Taglist:update()
    local tags = self.s.tags

    self.content_layout:reset()

    for _, tag in ipairs(tags) do
        self.content_layout:add(WorkspaceItem(tag))
    end
end

function Taglist:hook_update()
    local function doupdate()
        gtimer.delayed_call(function ()
            self:update()
        end)
    end

    doupdate()
end

function Taglist:render()
    self:hook_update()

    return self.content_layout
end

return oop(Taglist)