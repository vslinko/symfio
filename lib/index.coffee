unloader = require "./unloader"
kantaina = require "kantaina"
loader = require "./loader"
logger = require "./logger"

module.exports = (name, applicationDirectory) ->
  instance = kantaina()

  instance.set "name", name
  instance.set "application directory", applicationDirectory
  instance.set "silent", false
  instance.set "logger", logger
  instance.set "loader", loader
  instance.set "unloader", unloader

  instance

module.exports.loader = loader
module.exports.logger = logger
module.exports.unloader = unloader
