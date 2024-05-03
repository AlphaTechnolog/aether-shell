local wibox      = require("wibox")
local gtimer     = require("gears.timer")
local animation  = require("framework.animation")
local icon_theme = require("framework.icon-theme")()
local utils      = require("framework.utils")
local oop        = require("framework.oop")
local color      = require("framework.color")
local beautiful  = require("beautiful")
local dpi        = beautiful.xresources.apply_dpi

local tasklist   = {
    s = nil
}

function tasklist:constructor(s)
    if not self.s then
        self.s = s
    end
end

function tasklist:get_clients()
    local tag = self.s.selected_tag

    if not tag then
        return nil
    end

    return utils:reverse(tag:clients())
end

local function TaskListItem(client_instance)
    local light_background = color.lighten(beautiful.colors.background, 12)

    local computed_widget = wibox.widget({
        id = "background-element",
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

    local function get_background(is_active)
        return is_active and beautiful.colors.blue or light_background
    end

    local function get_foreground(is_active)
        return is_active and beautiful.colors.background or beautiful.colors.foreground
    end

    local color_animation = animation:new({
        duration = 0.25,
        easing = animation.easing.inOutQuad,
        pos = {
            background = color.hex_to_rgba(get_background(client_instance.active)),
            foreground = color.hex_to_rgba(get_foreground(client_instance.active))
        },
        update = function(_, pos)
            if pos.background then
                computed_widget.bg = color.rgba_to_hex(pos.background)
            end
            if pos.foreground then
                computed_widget.fg = color.rgba_to_hex(pos.foreground)
            end
        end
    })

    function color_animation:set_state(new_state)
        self:set({
            background = color.hex_to_rgba(new_state.background),
            foreground = color.hex_to_rgba(new_state.foreground)
        })
    end

    computed_widget:add_button(utils:left_click(function()
        if client_instance.active then
            gtimer.delayed_call(function()
                -- this toggle will never happen though, the else will be dispatched instead.
                client_instance.minimized = not client_instance.minimized
            end)
        else
            client_instance:activate({
                switch_to_tag = false, -- it should be already in the current tag lol
                raise = true,
                context = "dock"
            })
        end
    end))

    local function subscribe_key(key, id, update)
        local element = computed_widget:get_children_by_id(id)[1]

        if not element then
            return
        end

        -- first update call, even before subscribing
        gtimer.delayed_call(function()
            if update then
                update(element, client_instance[key])
            end
        end)

        client_instance:connect_signal("property::" .. key, function(obj)
            if not obj then return end
            if update then update(element, obj[key]) end
        end)
    end

    subscribe_key("name", "name-element", function(element, name)
        element:set_markup_silently(utils:truncate_text(name, 40))
    end)

    -- using the background element since we dont really need a specific element
    subscribe_key("active", "background-element", function(_, is_active)
        color_animation:set_state({
            background = get_background(is_active),
            foreground = get_foreground(is_active),
        })
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
