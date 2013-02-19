# Launch express application after all plugins is loaded.
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.express
#     supply.wait "port", ->
#         supply.set "port", 80
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
module.exports = (supply, callback) ->
    supply.info "configuring", "express"

    app = express()
    server = http.createServer app

    app.configure ->
        app.use express.bodyParser()

    app.configure "development", ->
        app.use express.errorHandler()

    supply.set "app", app
    supply.set "port", process.env.PORT or 3000
    supply.set "server", server

    supply.on "loaded", ->
        port = supply.get "port"

        server.listen port, ->
            supply.info "listening", port

    callback()
