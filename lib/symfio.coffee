#### Welcome to Symfio documentation
#
# Symfio is a thin layer between Node.JS modules. Symfio allows you to
# connect Node.JS modules using a plugin system. Plugins are loaded
# asynchronously, which can reduce the time of application initialization.
container = require "./symfio/container"
unloader  = require "./symfio/unloader"
plugins   = require "./symfio/plugins"
loader    = require "./symfio/loader"
logger    = require "./symfio/logger"
path      = require "path"

createInstance = (name, applicationDirectory) ->
  fixturesDirectory = path.join applicationDirectory, "fixtures"
  publicDirectory   = path.join applicationDirectory, "public"
  uploadsDirectory  = path.join publicDirectory, "uploads"

  instance = container()

  instance.set "name", name
  instance.set "application directory", applicationDirectory
  instance.set "fixtures directory", fixturesDirectory
  instance.set "uploads directory", uploadsDirectory
  instance.set "public directory", publicDirectory
  instance.set "silent", false
  instance.set "logger", logger instance
  instance.set "loader", loader instance
  instance.set "unloader", unloader instance

  instance

module.exports           = createInstance
module.exports.container = container
module.exports.loader    = loader
module.exports.logger    = logger
module.exports.plugins   = plugins
module.exports.unloader  = unloader
