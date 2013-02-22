# require supplier module
supplier = require "../../lib/supplier"

# create container
container = supplier "hello world", __dirname
loader = container.get "loader"

# add dependent plugins
loader.use supplier.plugins.express
loader.use supplier.plugins.mongoose
loader.use supplier.plugins.fixtures

# define own plugin
loader.use (container, callback) ->
    # replace connection string
    loader.once "injected", ->
        container.set "connection string", "mongodb://localhost/hello_world"

    # after all dependencies is configured in container
    loader.once "configured", ->
        # get dependencies
        connection = container.get "connection"
        mongoose = container.get "mongoose"
        app = container.get "app"

        # define schemas
        MessageSchema = new mongoose.Schema
            message: type: "string"

        # define models
        Message = connection.model "messages", MessageSchema

        # define express routes
        app.get "/", (req, res) ->
            Message.find {}, (err, messages) ->
                res.send messages

        # our plugin is configured and loaded, allow to start server
        callback.loaded()

    # our plugin injected values in container
    callback.injected()
    callback.configured()
