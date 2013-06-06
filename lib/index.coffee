unloader = require "./unloader"
kantaina = require "kantaina"
loader = require "./loader"

module.exports = (name, applicationDirectory) ->
  instance = kantaina()

  instance.set "name", name
  instance.set "application directory", applicationDirectory
  instance.set "silent", false
  instance.set "loader", loader
  instance.set "unloader", unloader

  instance

module.exports.loader = loader
module.exports.unloader = unloader
