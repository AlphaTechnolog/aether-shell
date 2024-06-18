local initialisation = require("framework.initialisation")()

-- performance improvements
initialisation:setup_garbage_collector_timer()

require("awful.hotkeys_popup.keys")
require("awful.autofocus")
require("framework.configuration.exposer")
require("framework.globals")

-- load theme and autostart before some ui rendering
initialisation:load_theme()
initialisation:load_autostart()

require("misc.error-handling")
require("base")
require("ui")
