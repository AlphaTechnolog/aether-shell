local wibox = require("wibox")
local gtimer = require("gears.timer")
local icon_theme = require("framework.icon-theme")()
local utils = require("framework.utils")
local oop = require("framework.oop")
local beautiful = require("beautiful")
local color = require("framework.color")
local dpi = beautiful.xresources.apply_dpi

local tasklist  = {}

function tasklist:constructor(s)
    self.s = s
end

function tasklist:get_clients()
    local tag = self.s.selected_tag

    if not tag then
        return nil
    end

    return tag:clients()
end

local function TaskListItem(client_instance)
    local light_background = color.lighten(beautiful.colors.background, 12)

    local computed_widget = wibox.widget({
        widget = wibox.container.background,
        bg = light_background,
        fg = beautiful.colors.foreground,
        shape = utils:srounded(dpi(7)),
        {
            widget = wibox.container.margin,
            margins = utils:xmargins(4, 4, 6, 6),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(4),
                {
                    widget = wibox.widget.imagebox,
                    image = icon_theme:get_client_icon_path(client_instance) or client_instance.icon,
                    valign = "center",
                    halign = "center",
                    forced_width = dpi(20),
                    forced_height = dpi(20),
                },
                {
                    id = "name-element",
                    markup = utils:truncate_text(client_instance.name, 40),
                    widget = wibox.widget.textbox,
                    valign = "center",
                    align = "center"
                }
            }
        }
    })

    local function subscribe_key(key, id, update)
        local element = computed_widget:get_children_by_id(id)[1]

        if not element then
            return
        end

        -- first update call, even before subscribing
        gtimer.delayed_call(function ()
            if update then
                update(element, client_instance[key])
            end
        end)

        client_instance:connect_signal("property::" .. key, function (obj)
            if not obj then return end
            if update then update(element, obj[key]) end
        end)
    end

    subscribe_key("name", "name-element", function (element, name)
        element:set_markup_silently(utils:truncate_text(name, 40))
    end)

    return computed_widget
end

local function update(self, container, layout)
    layout:reset()

    local clients = self:get_clients()

    if not clients then
        return
    end

    if #clients == 0 then
        container.bg = beautiful.colors.transparent
        return
    end

    container.bg = beautiful.colors.background

    for _, c in ipairs(clients) do
        layout:add(TaskListItem(c))
    end
end

function tasklist:render()
    local layout = wibox.layout.fixed.horizontal()
    layout.spacing = dpi(6)

    local container = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.colors.background,
        shape = utils:srounded(dpi(7)),
        {
            id = "margin-element",
            widget = wibox.container.margin,
            margins = dpi(6),
            layout,
        }
    })

    local function delayed_update()
        gtimer.delayed_call(function()
            update(self, container, layout)
        end)
    end

    local function callback_update(_)
        delayed_update()
    end

    callback_update()

    Client.connect_signal("list", callback_update)
    Tag.connect_signal("property::selected", callback_update)

    return container
end

return oop(tasklist)
