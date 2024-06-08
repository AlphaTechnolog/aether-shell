local awful = require("awful")

Client.connect_signal("request::manage", function(client)
  if
    client.floating
    or awful.layout.get(client.tag) == awful.layout.suit.floating
  then
    awful.placement.centered(client, {
      honor_workarea = true,
      honor_padding = true,
    })
  end
end)
