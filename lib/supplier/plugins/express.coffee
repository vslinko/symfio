# Launch express application after all plugins is loaded.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.express
#     loader.once "injected", ->
#         container.set "port", 80
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
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "injecting", "express"

    app = express()
    
    app.configure ->
        app.use express.bodyParser()

    app.configure "development", ->
        app.use express.errorHandler()
    
    server = http.createServer app

    container.set "app", app
    container.set "port", process.env.PORT or 3000
    container.set "server", server

    loader.once "loaded", ->
        port = container.get "port"

        server.listen port, ->
            logger.info "listening", port

    callback()
