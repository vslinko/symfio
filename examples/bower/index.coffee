supplier = require "../.."
fs = require "fs.extra"


container = supplier "bower-example", __dirname
container.set "public directory", __dirname
container.set "components", ["jquery"]

loader = container.get "loader"
loader.use supplier.plugins.express
loader.use supplier.plugins.assets
loader.use supplier.plugins.bower

loader.use (container, callback) ->
    unloader = container.get "unloader"

    unloader.register (callback) ->
        fs.remove "#{__dirname}/.components", ->
            fs.remove "#{__dirname}/components", ->
                callback()

    callback()


module.exports = container

if require.main is module
    loader.load()
