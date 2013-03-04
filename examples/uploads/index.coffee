symfio = require "../.."
path = require "path"
fs = require "fs.extra"


uploadsDirectory = path.join __dirname, "uploads"

container = symfio "uploads-example", __dirname
container.set "public directory", __dirname
container.set "uploads directory", uploadsDirectory

loader = container.get "loader"

loader.use (container, callback) ->
    fs.mkdir uploadsDirectory, ->
        callback()

loader.use symfio.plugins.express
loader.use symfio.plugins.assets
loader.use symfio.plugins.uploads

loader.use (container, callback) ->
    unloader = container.get "unloader"

    unloader.register (callback) ->
        fs.remove uploadsDirectory, ->
            callback()

    callback()


module.exports = container

if require.main is module
    loader.load()
