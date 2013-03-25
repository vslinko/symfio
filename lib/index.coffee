container = require "./container"
unloader = require "./unloader"
loader = require "./loader"
logger = require "./logger"

module.exports = (name, applicationDirectory) ->
  instance = container()

  instance.set "name", name
  instance.set "application directory", applicationDirectory
  instance.set "silent", false
  instance.set "logger", logger instance
  instance.set "loader", loader instance
  instance.set "unloader", unloader instance

  instance

module.exports.container = container
module.exports.loader = loader
module.exports.logger = logger
module.exports.unloader = unloader
