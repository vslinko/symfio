# Launch express application after all plugins is loaded.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     container.set "port", 80
#     loader = container.get "loader"
#     loader.use supplier.plugins.express
#     loader.load()
express = require "express"
http = require "http"


#### Provides:
#
# * __app__ — Express application.
# * __server__ — `http.Server` instance for express application.
#
#### Can be configured:
#
# * __port__ — Port for listening.
module.exports = (container, callback) ->
    unloader = container.get "unloader"
    loader = container.get "loader"
    logger = container.get "logger"
    port = container.get "port", process.env.PORT or 3000

    logger.info "loading plugin", "express"
    
    app = express()

    app.use express.bodyParser()

    app.configure "development", ->
        app.use express.errorHandler()

    server = http.createServer app

    container.set "app", app
    container.set "server", server

    loader.once "loaded", ->
        server.listen port, ->
            logger.info "listening", port

    unloader.register (callback) ->
        try
            server.close callback
        catch err
            callback()

    callback()
