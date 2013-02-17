# require supplier module
supplier = require "../../lib/supplier"

# create instance
supply = supplier()

# define own plugin
supply.use (supply, callback) ->
    # add dependent plugins
    supply.use supplier.plugins.express
    supply.use supplier.plugins.mongoose
    supply.use supplier.plugins.fixtures

    # configure
    supply.set "name", "hello world"
    supply.set "connection string", "mongodb://localhost/hello_world"
    supply.set "fixtures directory", "#{__dirname}/fixtures"

    # after all dependent is configured
    supply.on "configured", ->
        # get necessary variables
        connection = supply.get "connection"
        mongoose = supply.get "mongoose"
        app = supply.get "app"

        # define schemas
        MessageSchema = new mongoose.Schema
            message: type: "string"

        # define models
        Message = connection.model "messages", MessageSchema

        # define express routes
        app.get "/", (req, res) ->
            Message.find {}, (err, messages) ->
                res.send messages

        # our plugin is loaded, allow to start server
        callback.loaded()

    # our plugin is configured
    callback.configured()
