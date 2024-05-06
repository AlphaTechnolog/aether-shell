local wibox = require("wibox")
local gshape = require("gears.shape")
local gtimer = require("gears.timer")
local hoverable = require("ui.guards.hoverable")
local utils = require("framework.utils")()
local oop = require("framework.oop")
local animation = require("framework.animation")
local color = require("framework.color")
local icon_theme = require("framework.icon-theme")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local tasklist = {
    s = nil,
}

function tasklist:constructor(s)
    self.s = s
end

local function Launcher()
    local container = hoverable(wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        shape = utils:srounded(dpi(8)),
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(6, 6, 12, 12),
            {
                widget = wibox.container.background,
                shape = gshape.circle,
                forced_width = dpi(24),
                forced_height = dpi(24),
                valign = "center",
                halign = "center",
                border_color = beautiful.colors.accent,
                border_width = dpi(4),
                bg = beautiful.colors.transparent
            }
        }
    }))

    container:setup_hover({
        colors = {
            normal = beautiful.colors.background,
            hovered = beautiful.colors.light_background_10,
        }
    })

    return container
end

local function ClientButton(client)
    local container = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        shape = utils:srounded(dpi(7)),
        {
            widget = wibox.container.margin,
            margins = dpi(4),
            {
                widget = wibox.widget.imagebox,
                image = icon_theme:get_client_icon_path(client),
                valign = "center",
                halign = "center",
                forced_width = dpi(42),
                forced_height = dpi(42)
            }
        }
    })

    container.animation = animation:new({
        duration = 0.25,
        easing = animation.easing.inOutQuad,
        pos = color.hex_to_rgba(beautiful.colors.background),
        update = function (_, pos)
            container.bg = color.rgba_to_hex(pos)
        end
    })

    function container.animation:set_color(color_hex)
        self:set(color.hex_to_rgba(color_hex))
    end

    local function subscribed(key, callback)
        local function set_value()
            gtimer.delayed_call(function ()
                if callback ~= nil then
                    callback()
                end
            end)
        end

        set_value()
        client:connect_signal("property::" .. key, set_value)
    end

    subscribed("active", function ()
        container.animation:set_color(
            client.active
                and beautiful.colors.light_background_10
                or beautiful.colors.background
        )
    end)

    container:connect_signal("mouse::enter", function ()
        if client.active then
            container.animation:set_color(beautiful.colors.light_black_15)
        else
            container.animation:set_color(beautiful.colors.light_background_10)
        end
    end)

    container:connect_signal("mouse::leave", function ()
        if client.active then
            container.animation:set_color(beautiful.colors.light_background_10)
        else
            container.animation:set_color(beautiful.colors.background)
        end
    end)

    container:add_button(utils:left_click(function()
        client:activate({
            context = "dock",
            raise = true
        })
    end))

    return container
end

local function update_clients(self)
    local clients = self.s.selected_tag:clients()

    self.layout:reset()
    self.layout:add(Launcher())

    if #clients == 0 then
        return
    end

    for _, client in ipairs(clients) do
        self.layout:add(ClientButton(client))
    end
end

function tasklist:render()
    self.layout = wibox.layout.fixed.horizontal()
    self.layout.spacing = dpi(6)

    local function cb()
        gtimer.delayed_call(function ()
            update_clients(self)
        end)
    end

    cb()

    Client.connect_signal("list", cb);
    Client.connect_signal("swapped", cb);
    Client.connect_signal("property::active", cb);
    Tag.connect_signal("property::selected", cb);

    return self.layout
end

return oop(tasklist)