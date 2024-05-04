local json = require("extern.json.json")
local gfs = require("gears.filesystem")
local Meta = require("meta")
local oop = require("framework.oop")
local Fs = require("framework.fs-simple")
local utils = require("framework.utils")()

local _manager = {}

local DEFAULT_CACHED_ICONS = {
    icons = {}
}

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
local function register_value(filename, content)
    return { filename = filename, default_content = content}
end

function _manager:constructor(_)
    self.fs = Fs()
    self.config_dir = os.getenv("HOME") .. "/.config/" .. Meta.Project.id
    self.cache_dir = os.getenv("HOME") .. "/.cache/" .. Meta.Project.id

    self.icons_cache = self.cache_dir .. "/icons-cache.json"
    self.user_likes = self.config_dir .. "/user-likes.json"
    self.autostart = self.config_dir .. "/autostart.json"
    self.general_behavior = self.config_dir .. "/general-behavior.json"

    self.files = {
        ["icons_cache"] = register_value(self.icons_cache, DEFAULT_CACHED_ICONS),
        ["user_likes"] = register_value(self.user_likes, DEFAULT_USER_LIKES),
        ["autostart"] = register_value(self.autostart, DEFAULT_AUTOSTART),
        ["general_behavior"] = register_value(self.general_behavior, DEFAULT_GENERAL_BEHAVIOR)
    }

    self:scaffold_if_needed()
    self:make_parsing_functions_shortcuts()
end

-- TODO: Figure out a way to prettify the json
function _manager:write_into(filename, content_table)
    local content = json.encode(content_table)
    local file = io.open(filename, "w")

    if not file then
        error("cannot open the file " .. filename)
    end

    file:write(content)
    file:close()
end

function _manager:scaffold_if_needed()
    self.fs:xmkdir(self.config_dir)
    self.fs:xmkdir(self.cache_dir)

    for _, content in pairs(self.files) do
        local filename, default_content =
            content.filename, content.default_content

        if not self.fs:isfile(filename) then
            self.fs:touch(filename)
            self:write_into(filename, default_content)
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
---     return self:parse(self.general_behavior)
--- end
function _manager:make_parsing_functions_shortcuts()
    for name, content in pairs(self.files) do
        self["parse_" .. name] = function (self)
            return self:parse(content.filename)
        end
    end
end

-- TODO: Use a more sophisticated error instead of `error()`
function _manager:inject_helpers(filename_key, tbl)
    local _injected_functions = {
        "get_key",
        "refresh_content"
    }

    local manager_self = self

    local function resolve_filename()
        for key, meta in pairs(manager_self.files) do
            local filename = meta.filename
            if key == filename_key then
                return filename
            end
        end

        return nil
    end

    local filename = resolve_filename()

    if filename == nil then
        error("invalid given filename key " .. filename_key)
    end

    function tbl:get_key(key)
        if not utils:key_in_tbl(key, tbl) then
            error("cannot get required key " .. key .. " from the config files!")
        end

        return self[key]
    end

    function tbl:refresh_content()
        local value = {}

        for key, val in pairs(self) do
            local is_injected = false

            for _, injected_key in ipairs(_injected_functions) do
                if key == injected_key then
                    is_injected = true
                    goto stop
                end

                ::stop::
            end

            if not is_injected then
                value[key] = val
            end
        end

        manager_self:write_into(filename, value)

        return value
    end

    return tbl
end

return oop(_manager)
