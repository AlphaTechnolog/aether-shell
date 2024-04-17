--  ___                     _
-- |_ _|_ __  _ __  ___ _ _| |_ ___
--  | || '  \| '_ \/ _ \ '_|  _(_-<
-- |___|_|_|_| .__/\___/_|  \__/__/
--           |_|

local xresources = require "beautiful.xresources"
local gfs = require "gears.filesystem"
local palette = require "framework.palette"()
local dpi = xresources.apply_dpi

local themes_path = gfs.get_themes_dir()

local theme = {}

--  ___        _
-- | __|__ _ _| |_ ___
-- | _/ _ \ ' \  _(_-<
-- |_|\___/_||_\__/__/

theme.fonts = {
  normal = "Inter ",
  icons = "Material Symbols Rounded ",
  nerdfonts = "Iosevka Nerd Font ",
}

function theme.fonts:choose(family, size)
  return self[family] .. tostring(size)
end

theme.font = theme.fonts:choose("normal", 9)

--  ___     _
-- / __|___| |___ _ _ ___
-- | (__/ _ \ / _ \ '_(_-<
-- \___\___/_\___/_| /__/

theme.colors = palette:generate_shades({
  transparent = "#00000000",
  background = "#141414",
  foreground = "#C7CCD1",
  black = "#1f1f1f",
  red = "#C79595",
  green = "#AEC795",
  yellow = "#C7C795",
  blue = "#95AEC7",
  magenta = "#AE95C7",
  cyan = "#95C7AE",
  white = "#DFE2E5",
})

-- accent color
-- TODO: Add a popup to customize this color
theme.colors.accent = theme.colors.blue

theme.bg_normal = theme.colors.background
theme.fg_normal = theme.colors.foreground

theme.bg_systray = theme.bg_normal
theme.fg_systray = theme.fg_normal

--  ___                       _
-- / __|___ _ _  ___ _ _ __ _| |
-- | (_ / -_) ' \/ -_) '_/ _` | |
-- \___\___|_||_\___|_| \__,_|_|

theme.useless_gap = dpi(5)
theme.border_width = dpi(0)
theme.border_color_normal = theme.colors.light_background_8
theme.border_color_active = theme.colors.light_background_15
theme.border_color_marked = theme.colors.light_background_8
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)
theme.icon_theme = "Papirus-Dark"

--  _                       _
-- | |   __ _ _  _ ___ _  _| |_
-- | |__/ _` | || / _ \ || |  _|
-- |____\__,_|\_, \___/\_,_|\__|
--            |__/

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
