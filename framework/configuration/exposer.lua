local Manager = require("framework.configuration.manager")
local manager = Manager()

Configuration = {
  IconsCache = manager:inject_helpers(
    "icons_cache",
    manager:parse_icons_cache()
  ),
  UserLikes = manager:inject_helpers("user_likes", manager:parse_user_likes()),
  Autostart = manager:inject_helpers("autostart", manager:parse_autostart()),
  GeneralBehavior = manager:inject_helpers(
    "general_behavior",
    manager:parse_general_behavior()
  ),
}
