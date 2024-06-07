local awful = require("awful")
local gshape = require("gears.shape")
local oop = require("framework.oop")
local color = require("framework.color")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local _utils = {}

function _utils:srounded(fact)
  return function(cr, w, h)
    gshape.rounded_rect(cr, w, h, fact)
  end
end

function _utils:prounded(fact, tl, tr, br, bl)
  return function(cr, w, h)
    gshape.partially_rounded_rect(cr, w, h, tl, tr, br, bl, fact)
  end
end

function _utils:range(x, y)
  local i, ret = x, {}
  while i <= y do
    table.insert(ret, i)
    i = i + 1
  end
  return ret
end

function _utils:xmargins(t, b, l, r)
  return {
    top = dpi(t),
    bottom = dpi(b),
    left = dpi(l),
    right = dpi(r),
  }
end

function _utils:map(tbl, iterator, cb)
  local result = {}

  for a, b in iterator(tbl) do
    table.insert(result, cb(a, b))
  end

  return result
end

function _utils:filter(tbl, iterator, cb)
  local result = {}

  for a, b in iterator(tbl) do
    if cb(a, b) then
      table.insert(result, iterator == pairs and { [a] = b } or b)
    end
  end

  return result
end

function _utils:find(tbl, iterator, cb)
  local ret = self:filter(tbl, iterator, cb)
  return #ret == 0 and nil or ret[1]
end

function _utils:mapped_range(x, y, mapper)
  local orig = self:range(x, y)
  local ret = {}

  for _, x in ipairs(orig) do
    table.insert(ret, mapper(x))
  end

  return ret
end

function _utils:left_click(cb)
  return awful.button({}, 1, function()
    if cb then
      cb()
    end
  end)
end

function _utils:key_in_tbl(key, tbl)
  local result = false

  for name, _ in pairs(tbl) do
    if name == key then
      result = true
      goto stop
    end
  end

  ::stop::

  return result
end

function _utils:truncate_text(text, max_length)
  if string.len(text) < max_length then
    return text
  end

  local suffix = "..."
  local truncated_text = string.sub(text, 1, max_length - string.len(suffix))
    .. suffix

  return truncated_text
end

-- https://stackoverflow.com/questions/72783502/how-does-one-reverse-the-items-in-a-table-in-lua
function _utils:reverse(tab)
  for i = 1, math.floor(#tab / 2), 1 do
    tab[i], tab[#tab - i + 1] = tab[#tab - i + 1], tab[i]
  end

  return tab
end

function _utils:max(a, b)
  return a > b and a or b
end

function _utils:min(a, b)
  return a < b and a or b
end

function _utils:color_adaptive_shade(hex_color, amount)
  if beautiful.scheme == "light" then
    return color.darken(hex_color, amount * 2)
  else
    return color.lighten(hex_color, amount)
  end
end

return oop(_utils)
