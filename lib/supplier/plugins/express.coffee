express = require "express"
http = require "http"


module.exports = (supply, callback) ->
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
        server.listen supply.get "port"

    callback()
