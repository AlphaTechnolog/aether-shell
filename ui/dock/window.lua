local wibox = require("wibox")
local awful = require("awful")
local gtimer = require("gears.timer")
local animation = require("framework.animation")
local oop = require("framework.oop")
local utils = require("framework.utils")()
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local window = {}

function window:constructor(s)
    self.s = s
    self:make_widget()
end

-- default minimum geometry
local function geometry()
    return {
        width = dpi(250),
        height = dpi(42),
    }
end

function window:make_widget()
    local geo = geometry()

    self.popup = awful.popup({
        screen = self.s,
        minimum_width = geo.width,
        maximum_width = self.s.geometry.width - beautiful.useless_gap * 4,
        minimum_height = geo.height,
        maximum_height = geo.height,
        x = 0,
        y = 0,
        bg = beautiful.colors.transparent,
        fg = beautiful.colors.foreground,
        visible = false,
        ontop = true,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.colors.background,
            shape = utils:srounded(dpi(12)),
            {
                widget = wibox.container.margin,
                margins = utils:xmargins(6, 6, 8, 8),
                {
                    widget = wibox.widget.textbox,
                    markup = 'center',
                    valign = 'center',
                    align = 'center',
                }
            }
        }
    })
    
    function self.popup:repositionate(window)
        local function calculate()
            local s = self.screen

            local new_state = {
                x = s.geometry.x + ((s.geometry.width - self.width) / 2),
                y = s.geometry.y + ((s.geometry.height - self.height) - beautiful.useless_gap * 2)
            }

            -- use the animation only after first time
            -- FIXME: still showing positioning animation on boot
            if (self.x == 0 or self.y == 0) or not window.animation then
                self.x = new_state.x
                self.y = new_state.y
            else
                local window_animation = window.animation
                window_animation:set(new_state)
            end
        end

        calculate()

        self:connect_signal("property::width", function (_)
            calculate()
        end)

        self:connect_signal("property::height", function (_)
            calculate()
        end)
    end

    self.popup:repositionate(self)
    self:make_animation()
    self:apply_clients_listeners()
end

local WINDOW_STATUS = {
    HIDDING = 'HIDDING',
    SHOWING = 'SHOWING',
    IDLE = 'IDLE',
}

function window:make_animation()
    self.status = WINDOW_STATUS.IDLE

    self.animation = animation:new({
        duration = 0.25,
        easing = animation.easing.inOutQuad,
        pos = {
            x = self.popup.x,
            y = self.popup.y,
        },
        update = function (_, pos)
            self.popup.x = pos.x
            self.popup.y = pos.y
        end,
        signals = {
            ["ended"] = function ()
                if self.status == WINDOW_STATUS.HIDDING then
                    -- closing the popup when needed
                    self.popup.visible = false
                end

                self.status = WINDOW_STATUS.IDLE
            end
        }
    })
end

function window:show_popup()
    if self.popup.visible == true then
        print("[warning] window:show_popup(): can't show popup since self.popup.visible is already on")
        return
    end

    self.popup.visible = true
    self.status = WINDOW_STATUS.SHOWING

    self.animation:set({
        x = self.popup.x, -- leave x as how it's
        y = self.s.geometry.y + ((self.s.geometry.height - self.popup.height) - beautiful.useless_gap * 2)
    })
end

function window:hide_popup()
    -- this indicates the animation to make it invisible when it gets done
    -- note that status gets resetted to idle after that
    self.status = WINDOW_STATUS.HIDDING

    self.animation:set({
        x = self.popup.x,
        y = self.s.geometry.y + self.s.geometry.height + beautiful.useless_gap * 2
    })
end

local function should_hide_panel(self)
    local client = Client.focus

    -- if no focused client, then, don't hide it ;)
    if not client then
        return false
    end

    local is_floating = client.floating or awful.layout.get(self.s) == awful.layout.suit.floating
    
    if not is_floating then
        return true
    end

    local geo = {
        client = client:geometry(),
        dock = {
            x = self.popup.x,
            y = self.popup.y,
            width = self.popup.width,
            height = self.popup.height
        }
    }

    return (
        geo.dock.x >= geo.client.x and
        geo.dock.x + geo.dock.width <= geo.client.x + geo.client.width and
        geo.dock.y <= geo.client.y + geo.client.height
    )
end

function window:apply_clients_listeners()
    local function update_state()
        gtimer.delayed_call(function ()
            if should_hide_panel(self) then
                print("should_hide_panel() -> true")
                self:hide_popup()
            else
                print("should_hide_panel() -> false")
                self:show_popup()
            end
        end)
    end

    Client.connect_signal("list", update_state)
    Client.connect_signal("property::floating", update_state)
    Client.connect_signal("property::geometry", update_state)
    Tag.connect_signal("property::selected", update_state)
    Tag.connect_signal("property::layout", update_state)

    update_state()
end

function window:raise()
    self.popup.visible = true
end

function window:hide()
    self.popup.visible = false
end

return oop(window)