supplier = require "../.."
path = require "path"
fs = require "fs.extra"


uploadsDirectory = path.join __dirname, "uploads"

container = supplier "uploads-example", __dirname
container.set "public directory", __dirname
container.set "uploads directory", uploadsDirectory

loader = container.get "loader"

loader.use (container, callback) ->
    fs.mkdir uploadsDirectory, ->
        callback()

loader.use supplier.plugins.express
loader.use supplier.plugins.assets
loader.use supplier.plugins.uploads

loader.use (container, callback) ->
    unloader = container.get "unloader"

    unloader.register (callback) ->
        fs.remove uploadsDirectory, ->
            callback()

    callback()


module.exports = container

if require.main is module
    loader.load()
