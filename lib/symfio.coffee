#### Welcome to Symfio documentation
#
# Symfio is a thin layer between Node.JS modules. Symfio allows you to
# connect Node.JS modules using a plugin system. Plugins are loaded
# asynchronously, which can reduce the time of application initialization.
container = require "./symfio/container"
unloader  = require "./symfio/unloader"
loader    = require "./symfio/loader"
logger    = require "./symfio/logger"
test      = require "./symfio/test"
path      = require "path"

createInstance = (name, applicationDirectory) ->
  instance = container()

  instance.set "name", name
  instance.set "application directory", applicationDirectory
  instance.set "silent", false
  instance.set "logger", logger instance
  instance.set "loader", loader instance
  instance.set "unloader", unloader instance

  instance

module.exports           = createInstance
module.exports.container = container
module.exports.loader    = loader
module.exports.logger    = logger
module.exports.test      = test
module.exports.unloader  = unloader
