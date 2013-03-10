symfio = require "../.."
fs     = require "fs.extra"

container = symfio "bower-example", __dirname
container.set "public directory", __dirname
container.set "components", ["jquery"]

loader = container.get "loader"
loader.use symfio.plugins.express
loader.use symfio.plugins.assets
loader.use symfio.plugins.bower

loader.use (container, callback) ->
  unloader = container.get "unloader"

  unloader.register (callback) ->
    fs.remove "#{__dirname}/.components", ->
      fs.remove "#{__dirname}/components", ->
        callback()

  callback()

loader.load() if require.main is module
module.exports = container
