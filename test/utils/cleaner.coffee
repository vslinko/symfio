async = require "async"
path = require "path"
fs = require "fs.extra"


cleaner = (container, cleaners, callback) ->
    worker = (cleaner, callback) ->
        cleaner container, callback

    async.forEach cleaners, worker, callback

assets = (container, callback) ->
    publicDirectory = container.get "public directory"
    cssFilePath = path.join publicDirectory, "style.css"
    fs.unlink cssFilePath, ->
        callback()

bower = (container, callback) ->
    applicationDirectory = container.get "application directory"
    publicDirectory = container.get "public directory"

    componentsDirectory = path.join publicDirectory, "components"
    fs.rmrf componentsDirectory, ->

        hashFile = path.join applicationDirectory, ".components"
        fs.unlink hashFile, ->
            callback()

express = (container, callback) ->
    try
        server = container.get "server"
        server.close callback
    catch err
        callback()

mongoose = (container, callback) ->
    connection = container.get "connection"

    return callback() unless connection.readyState is 1

    connection.db.dropDatabase ->
        connection.close ->
            callback()

uploads = (container, callback) ->
    uploadsDirectory = container.get "uploads directory"
    fs.rmrf uploadsDirectory, ->
        callback()


module.exports = cleaner
module.exports.assets = assets
module.exports.bower = bower
module.exports.express = express
module.exports.mongoose = mongoose
module.exports.uploads = uploads
