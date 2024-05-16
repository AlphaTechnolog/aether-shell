local oop = require("framework.oop")
local color = require("framework.color")

local _palette = {}

local shades_count = 15 -- number of shades to generate
local step = 2 -- how much will be the % of difference between colors

function _palette:generate_shades(scheme, base_palette)
  local ret = {}

  for name, hex in pairs(base_palette) do
    if name == "transparent" then
      goto continue
    end

    ret[name] = hex

    local i = 1

    while i <= shades_count do
      -- invert them if so
      local dark_key = scheme == "dark" and "dark" or "light"
      local light_key = scheme == "dark" and "light" or "dark"

      ret[dark_key .. "_" .. name .. "_" .. tostring(i)] =
        color.darken(hex, i * step)

      ret[light_key .. "_" .. name .. "_" .. tostring(i)] =
        color.lighten(hex, i * step)

      i = i + 1
    end

    ::continue::
  end

  return ret
end

return oop(_palette)
