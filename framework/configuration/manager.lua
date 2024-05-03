local json = require("extern.json.json")
local gfs = require("gears.filesystem")
local Meta = require("meta")
local oop = require("framework.oop")
local Fs = require("framework.fs-simple")
local utils = require("framework.utils")()

local _manager = {}

local DEFAULT_USER_LIKES = {
  navigator = "google-chrome",
  terminal = "alacritty",
  explorer = "thunar",
  launcher = "rofi -show drun",
  modkey = "Mod4",
  wallpaper = {
    filename = gfs.get_configuration_dir() .. "/assets/wallpaper.png",
    rounded_corners = {
      roundness = 12,
      top_left = true,
      top_right = true,
      bottom_left = true,
      bottom_right = true
    },
  }
}

local DEFAULT_GENERAL_BEHAVIOR = {
  num_tags = 6,
  sloppy_focus = true
}

local DEFAULT_AUTOSTART = {
  "bash -c 'pgrep -x pulseaudio || pulseaudio -b'",
  "bash -c 'pgrep -x picom || picom -b'"
}

-- utility function to speedup a little bit
local function registry_value(filename, content)
  return { filename = filename, default_content = content}
end

function _manager:constructor(_)
  self.fs = Fs()
  self.config_dir = os.getenv("HOME") .. "/.config/" .. Meta.Project.id
  self.user_likes = self.config_dir .. "/user-likes.json"
  self.autostart = self.config_dir .. "/autostart.json"
  self.general_behavior = self.config_dir .. "/general-behavior.json"

  self.files = {
    ["user_likes"] = registry_value(self.user_likes, DEFAULT_USER_LIKES),
    ["autostart"] = registry_value(self.autostart, DEFAULT_AUTOSTART),
    ["general_behavior"] = registry_value(self.general_behavior, DEFAULT_GENERAL_BEHAVIOR)
  }

  self:scaffold_if_needed()
  self:make_parsing_functions_shortcuts()
end

-- TODO: Figure out a way to prettify the json
function _manager:write_default(filename, content_string)
  local content = json.encode(content_string)
  local file = io.open(filename, "a+")

  if not file then
    error("cannot open the file " .. filename)
  end

  file:write(content)
  file:close()
end

function _manager:scaffold_if_needed()
  self.fs:xmkdir(self.config_dir)

  for _, content in pairs(self.files) do
    local filename, default_content =
      content.filename, content.default_content

    if not self.fs:isfile(filename) then
      self.fs:touch(filename)
      self:write_default(filename, default_content)
    end
  end
end

function _manager:parse(path)
  if not self.fs:isfile(path) then
    error(path .. " does not exists, did the caller call scaffold_if_needed()?")
  end

  return json.decode(self.fs:read(path))
end

-- generates functions that looks like this for every file:
--- function _manager:parse_general_behavior()
---   return self:parse(self.general_behavior)
--- end
function _manager:make_parsing_functions_shortcuts()
  for name, content in pairs(self.files) do
    self["parse_" .. name] = function (self)
      print(content.filename)
      return self:parse(content.filename)
    end
  end
end

-- TODO: Use a more sophisticated error instead of `error()`
function _manager:inject_helpers(tbl)
  function tbl:get_key(key)
    if not utils:key_in_tbl(key, tbl) then
      error("cannot get required key " .. key .. " from the config files!")
    end
    return self[key]
  end

  return tbl
end

return oop(_manager)
