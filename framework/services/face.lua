local gfs = require("gears.filesystem")
local utils = require("framework.utils")()
local oop = require("framework.oop")

local face = {}

function face:fetch()
  local default_face_path = gfs.get_configuration_dir()
    .. "assets/icons/face.default.png"

  local pos = utils:map({ "jpg", "png", "svg" }, ipairs, function(_, item)
    return os.getenv("HOME") .. "/.face." .. item
  end)

  local path = utils:find(pos, ipairs, function(_, path)
    return gfs.file_readable(path)
  end) or default_face_path

  return path
end

return oop(face)
