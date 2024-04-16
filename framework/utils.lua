local oop = require("framework.oop")

local _utils = {}

function _utils:range(x, y)
  local i, ret = x, {}
  while i <= y do
    table.insert(ret, i)
    i = i + 1
  end
  return ret
end

function _utils:mapped_range(x, y, mapper)
  local orig = self:range(x, y)
  local ret = {}

  for _, x in ipairs(orig) do
    table.insert(ret, mapper(x))
  end

  return ret
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

return oop(_utils)