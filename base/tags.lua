local awful = require("awful")
local utils = require("framework.utils")()

Screen.connect_signal("request::desktop_decoration", function(s)
  local num_tags = Configuration.GeneralBehavior:get_key("num_tags")
  local tags = utils:mapped_range(1, num_tags, tostring)
  awful.tag(tags, s, awful.layout.layouts[1])
end)
