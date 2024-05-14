--    ___                                         _
-- |_ _|_ __    _ __    ___ _ _| |_ ___
--    | || '    \| '_ \/ _ \ '_|    _(_-<
-- |___|_|_|_| .__/\___/_|    \__/__/
--                     |_|

local xresources = require("beautiful.xresources")
local gfs = require("gears.filesystem")
local palette = require("framework.palette")()
local dpi = xresources.apply_dpi

local themes_path = gfs.get_themes_dir()

local theme = {}

--    ___                _
-- | __|__ _ _| |_ ___
-- | _/ _ \ ' \    _(_-<
-- |_|\___/_||_\__/__/

theme.fonts = {
  normal = "Roboto ",
  icons = "Material Symbols Rounded ",
  nerdfonts = "Iosevka Nerd Font ",
}

function theme.fonts:choose(family, size)
  return self[family] .. tostring(size)
end

theme.font = theme.fonts:choose("normal", 9)

--    ___         _
-- / __|___| |___ _ _ ___
-- | (__/ _ \ / _ \ '_(_-<
-- \___\___/_\___/_| /__/

theme.colors = palette:generate_shades({
  background = "#131313",
  foreground = "#b6beca",
  black = "#202020",
  hovered_black = "#2c2c2c",
  red = "#c6797c",
  green = "#8cc7a9",
  yellow = "#dcc89f",
  blue = "#89a8d2",
  magenta = "#c29eda",
  cyan = "#8bb8d2",
  white = "#e0e1e4",
})

-- transparent bg
theme.colors.transparent = theme.colors.background .. "00"

-- accent color
function theme.colors:apply_shade(key)
  return { regular = self[key] .. "1A", bright = self[key] .. "33" }
end

-- TODO: Add a popup to customize this color
theme.colors.accent = theme.colors.cyan
theme.colors.secondary_accent = theme.colors.magenta

local accent_shade = theme.colors:apply_shade("accent")
theme.colors.accent_shade = accent_shade.regular
theme.colors.light_accent_shade = accent_shade.bright

theme.bg_normal = theme.colors.background
theme.fg_normal = theme.colors.foreground

theme.bg_systray = theme.bg_normal
theme.fg_systray = theme.fg_normal

--    ___                                             _
-- / __|___ _ _    ___ _ _ __ _| |
-- | (_ / -_) ' \/ -_) '_/ _` | |
-- \___\___|_||_\___|_| \__,_|_|

theme.useless_gap = dpi(4)
theme.border_width = dpi(1)
theme.border_color_normal = theme.colors.light_black_10
theme.border_color_active = theme.colors.light_hovered_black_15
theme.border_color_marked = theme.colors.light_black_15
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)
theme.icon_theme = "Papirus-Dark"

--    _                                             _
-- | |     __ _ _    _ ___ _    _| |_
-- | |__/ _` | || / _ \ || |    _|
-- |____\__,_|\_, \___/\_,_|\__|
--                        |__/

theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

return theme
