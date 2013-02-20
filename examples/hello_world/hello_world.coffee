# require supplier module
supplier = require "../../lib/supplier"

# create container
container = supplier "hello world"
loader = container.get "loader"

# add dependent plugins
loader.use supplier.plugins.express
loader.use supplier.plugins.mongoose
loader.use supplier.plugins.fixtures

# define own plugin
loader.use (container, callback) ->
    # configure
    container.set "connection string", "mongodb://localhost/hello_world"
    container.set "fixtures directory", "#{__dirname}/fixtures"

    # after all dependencies is injected in container
    loader.once "injected", ->
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
        callback.configured()
        callback.loaded()

    # our plugin injected values in container
    callback.injected()
