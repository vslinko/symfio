async = require "async"
path = require "path"
fs = require "fs.extra"


cleaner = (container, cleaners, callback) ->
    worker = (cleaner, callback) ->
        cleaner container, callback

    async.forEach cleaners, worker, ->
        unloader = container.get "unloader"
        unloader.unload callback

assets = (container, callback) ->
    publicDirectory = container.get "public directory"
    cssFilePath = path.join publicDirectory, "style.css"

    fs.unlink cssFilePath, ->
        callback()

bower = (container, callback) ->
    applicationDirectory = container.get "application directory"
    publicDirectory = container.get "public directory"
    componentsDirectory = path.join publicDirectory, "components"
    hashFile = path.join applicationDirectory, ".components"

    fs.rmrf componentsDirectory, ->
        fs.unlink hashFile, ->
            callback()

mongoose = (container, callback) ->
    connection = container.get "connection"

    return callback() unless connection.readyState is 1

    connection.db.dropDatabase ->
        callback()

uploads = (container, callback) ->
    uploadsDirectory = container.get "uploads directory"

    fs.rmrf uploadsDirectory, ->
        callback()


module.exports = cleaner
module.exports.assets = assets
module.exports.bower = bower
module.exports.mongoose = mongoose
module.exports.uploads = uploads
