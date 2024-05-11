local animation = require("framework.animation")
local color = require("framework.color")
local beautiful = require("beautiful")

return function(widget)
  function widget:setup_hover(opts)
    self.opts = opts
    self.animation = animation:new({
      duration = 0.25,
      easing = animation.easing.inOutQuad,
      pos = color.hex_to_rgba(
        opts.colors.normal or beautiful.colors.background
      ),
      update = function(_, pos)
        widget.bg = color.rgba_to_hex(pos)
      end,
    })

    self:subscribe_hover()
  end

  function widget:use_color(new_color)
    if not self.animation then
      error("[widget:hoverable] no animation yet, call setup() first")
    end

    self.animation:set({ target = color.hex_to_rgba(new_color) })
  end

  function widget:subscribe_hover()
    self:connect_signal("mouse::enter", function()
      self:use_color(self.opts.colors.hovered)
    end)
    self:connect_signal("mouse::leave", function()
      self:use_color(self.opts.colors.normal)
    end)
  end

  return widget
end
