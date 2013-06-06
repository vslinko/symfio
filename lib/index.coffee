kantaina = require "kantaina"
unloader = require "./unloader"
loader = require "./loader"


module.exports = (name, applicationDirectory) ->
  container = kantaina()

  container.set "name", name
  container.set "applicationDirectory", applicationDirectory
  container.set "loader", loader
  container.set "unloader", unloader

  container


module.exports.loader = loader
module.exports.unloader = unloader
