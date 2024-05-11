if Configuration.GeneralBehavior:get_key("sloppy_focus") then
  Client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
  end)
end
