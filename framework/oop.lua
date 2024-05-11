local gtable = require("gears.table")
local gobject = require("gears.object")

local setmetatable = setmetatable

return function(prototype)
  prototype.mt = {}

  if not prototype.constructor then
    prototype.constructor = function(_)
      -- @unimplemented
    end
  end

  local function new(...)
    local ret = gobject({})
    gtable.crush(ret, prototype, true)

    ret._private = {}
    ret:constructor(...)

    return ret
  end

  function prototype.mt:__call(...)
    return new(...)
  end

  return setmetatable(prototype, prototype.mt)
end
