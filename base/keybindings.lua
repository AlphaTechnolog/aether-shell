-- TODO: Organise this mess

-- NOTE: this file is a mess currently as there're
-- more features with more priority than "organising the keybindings file"

local awful = require('awful')
local gtimer = require('gears.timer')

local modkey = Configuration.UserLikes:get_key('modkey')
local terminal = Configuration.UserLikes:get_key('terminal')
local launcher = Configuration.UserLikes:get_key('launcher')

awful.mouse.append_global_mousebindings({
  awful.button({}, 4, awful.tag.viewprev),
  awful.button({}, 5, awful.tag.viewnext),
})

awful.keyboard.append_global_keybindings({
  awful.key(
    { modkey, 'Shift' },
    'r',
    Awesome.restart,
    { description = 'reload Awesome', group = 'Awesome' }
  ),
  awful.key(
    { modkey, 'Shift' },
    'q',
    Awesome.quit,
    { description = 'quit Awesome', group = 'Awesome' }
  ),
  awful.key({ modkey }, 'Return', function()
    awful.spawn("bash -c '" .. terminal .. "'")
  end, { description = 'open a terminal', group = 'launcher' }),
  awful.key({ modkey }, 'c', function()
    if
      Client.focus
      and (
        Client.focus.floating
        or awful.layout.get(Client.focus.tag) == awful.layout.suit.floating
      )
    then
      awful.placement.centered(Client.focus)
    end
  end, { description = 'center a client', group = 'idk' }),
  awful.key({ modkey, 'Shift' }, 'Return', function()
    awful.spawn("bash -c '" .. launcher .. "'")
  end, { description = 'spawn the user launcher', group = 'launcher' }),
  awful.key({ modkey }, 'd', function()
    local s = awful.screen.focused()

    if not s then
      return
    end

    local dashboard = s.dashboard

    if not dashboard then
      return
    end

    gtimer.delayed_call(function()
      dashboard:toggle()
    end)
  end, { description = 'open the dashboard', group = 'launcher' }),
})

awful.keyboard.append_global_keybindings({
  awful.key(
    { modkey },
    'Left',
    awful.tag.viewprev,
    { description = 'view previous', group = 'tag' }
  ),
  awful.key(
    { modkey },
    'Right',
    awful.tag.viewnext,
    { description = 'view next', group = 'tag' }
  ),
  awful.key(
    { modkey },
    'Escape',
    awful.tag.history.restore,
    { description = 'go back', group = 'tag' }
  ),
})

awful.keyboard.append_global_keybindings({
  awful.key({ modkey }, 'j', function()
    awful.client.focus.byidx(1)
  end, { description = 'focus next by index', group = 'Client' }),
  awful.key({ modkey }, 'k', function()
    awful.client.focus.byidx(-1)
  end, { description = 'focus previous by index', group = 'Client' }),
  awful.key({ modkey }, 'Tab', function()
    awful.client.focus.history.previous()
    if Client.focus then
      Client.focus:raise()
    end
  end, { description = 'go back', group = 'Client' }),
  awful.key({ modkey, 'Control' }, 'j', function()
    awful.screen.focus_relative(1)
  end, { description = 'focus the next screen', group = 'screen' }),
  awful.key({ modkey, 'Control' }, 'k', function()
    awful.screen.focus_relative(-1)
  end, { description = 'focus the previous screen', group = 'screen' }),
  awful.key({ modkey, 'Control' }, 'n', function()
    local c = awful.client.restore()
    -- Focus restored Client
    if c then
      c:activate({ raise = true, context = 'key.unminimize' })
    end
  end, { description = 'restore minimized', group = 'Client' }),
})

awful.keyboard.append_global_keybindings({
  awful.key({ modkey, 'Shift' }, 'j', function()
    awful.client.swap.byidx(1)
  end, { description = 'swap with next Client by index', group = 'Client' }),
  awful.key({ modkey, 'Shift' }, 'k', function()
    awful.client.swap.byidx(-1)
  end, { description = 'swap with previous Client by index', group = 'Client' }),
  awful.key(
    { modkey },
    'u',
    awful.client.urgent.jumpto,
    { description = 'jump to urgent Client', group = 'Client' }
  ),
  awful.key({ modkey }, 'l', function()
    awful.tag.incmwfact(0.05)
  end, { description = 'increase master width factor', group = 'layout' }),
  awful.key({ modkey }, 'h', function()
    awful.tag.incmwfact(-0.05)
  end, { description = 'decrease master width factor', group = 'layout' }),
  awful.key(
    { modkey, 'Shift' },
    'h',
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    { description = 'increase the number of master Clients', group = 'layout' }
  ),
  awful.key(
    { modkey, 'Shift' },
    'l',
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    { description = 'decrease the number of master Clients', group = 'layout' }
  ),
  awful.key({ modkey, 'Control' }, 'h', function()
    awful.tag.incncol(1, nil, true)
  end, { description = 'increase the number of columns', group = 'layout' }),
  awful.key({ modkey, 'Control' }, 'l', function()
    awful.tag.incncol(-1, nil, true)
  end, { description = 'decrease the number of columns', group = 'layout' }),
  awful.key({ modkey }, 'space', function()
    awful.layout.inc(1)
  end, { description = 'select next', group = 'layout' }),
  awful.key({ modkey, 'Shift' }, 'space', function()
    awful.layout.inc(-1)
  end, { description = 'select previous', group = 'layout' }),
})

awful.keyboard.append_global_keybindings({
  awful.key({
    modifiers = { modkey },
    keygroup = 'numrow',
    description = 'only view tag',
    group = 'tag',
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  }),
  awful.key({
    modifiers = { modkey, 'Control' },
    keygroup = 'numrow',
    description = 'toggle tag',
    group = 'tag',
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end,
  }),
  awful.key({
    modifiers = { modkey, 'Shift' },
    keygroup = 'numrow',
    description = 'move focused Client to tag',
    group = 'tag',
    on_press = function(index)
      if Client.focus then
        local tag = Client.focus.screen.tags[index]
        if tag then
          Client.focus:move_to_tag(tag)
        end
      end
    end,
  }),
  awful.key({
    modifiers = { modkey, 'Control', 'Shift' },
    keygroup = 'numrow',
    description = 'toggle focused Client on tag',
    group = 'tag',
    on_press = function(index)
      if Client.focus then
        local tag = Client.focus.screen.tags[index]
        if tag then
          Client.focus:toggle_tag(tag)
        end
      end
    end,
  }),
  awful.key({
    modifiers = { modkey },
    keygroup = 'numpad',
    description = 'select layout directly',
    group = 'layout',
    on_press = function(index)
      local t = awful.screen.focused().selected_tag
      if t then
        t.layout = t.layouts[index] or t.layout
      end
    end,
  }),
})

Client.connect_signal('request::default_mousebindings', function()
  awful.mouse.append_client_mousebindings({
    awful.button({}, 1, function(c)
      c:activate({ context = 'mouse_click' })
    end),
    awful.button({ modkey }, 1, function(c)
      c:activate({ context = 'mouse_click', action = 'mouse_move' })
    end),
    awful.button({ modkey }, 3, function(c)
      c:activate({ context = 'mouse_click', action = 'mouse_resize' })
    end),
  })
end)

Client.connect_signal('request::default_keybindings', function()
  awful.keyboard.append_client_keybindings({
    awful.key({ modkey }, 'f', function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end, { description = 'toggle fullscreen', group = 'Client' }),
    awful.key({ modkey }, 'w', function(c)
      c:kill()
    end, { description = 'close', group = 'Client' }),
    awful.key(
      { modkey, 'Control' },
      'space',
      awful.client.floating.toggle,
      { description = 'toggle floating', group = 'Client' }
    ),
    awful.key({ modkey, 'Control' }, 'Return', function(c)
      c:swap(awful.client.getmaster())
    end, { description = 'move to master', group = 'Client' }),
    awful.key({ modkey }, 'o', function(c)
      c:move_to_screen()
    end, { description = 'move to screen', group = 'Client' }),
    awful.key({ modkey }, 't', function(c)
      c.ontop = not c.ontop
    end, { description = 'toggle keep on top', group = 'Client' }),
    awful.key({ modkey }, 'n', function(c)
      -- The Client currently has the input focus, so it cannot be
      -- minimized, since minimized Clients can't have the focus.
      c.minimized = true
    end, { description = 'minimize', group = 'Client' }),
    awful.key({ modkey }, 'm', function(c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = '(un)maximize', group = 'Client' }),
    awful.key({ modkey, 'Control' }, 'm', function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end, { description = '(un)maximize vertically', group = 'Client' }),
    awful.key({ modkey, 'Shift' }, 'm', function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end, { description = '(un)maximize horizontally', group = 'Client' }),
  })
end)
