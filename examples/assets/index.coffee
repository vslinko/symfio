symfio = require "../.."
async = require "async"
path = require "path"
fs = require "fs"


container = symfio "assets-example", __dirname
unloader = container.get "unloader"
loader = container.get "loader"

loader.use symfio.plugins.express
loader.use symfio.plugins.assets

unloader.register (callback) ->
    publicDirectory = container.get "public directory"

    fs.readdir publicDirectory, (err, files) ->
        return callback() if err

        worker = (file, callback) ->
            return callback() unless /\.(css|html|js)$/.test file
            file = path.join publicDirectory, file
            fs.unlink file, callback

        async.forEach files, worker, callback


module.exports = container

if require.main is module
    loader.load()
