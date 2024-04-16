local Manager = require("framework.configuration.manager")
local manager = Manager()

Configuration = {
  UserLikes = manager:inject_helpers(manager:parse_user_likes()),
  Autostart = manager:inject_helpers(manager:parse_autostart()),
  GeneralBehavior = manager:inject_helpers(manager:parse_general_behavior()),
}