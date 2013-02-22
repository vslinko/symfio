# Connect to MongoDB
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.mongoose
#     loader.once "injected", ->
#         container.set "connection string", "mongodb://localhost/test"
mongoose = require "mongoose"


#### Provides:
#
# * __connection__ — Mongoose connection instance.
# * __mongoose__ — `mongoose` module.
# * __mongodb__ — `mongodb` module.
#
#### Can be configured:
#
# * __connection string__ — MongoDB connection string.
#
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "injecting", "mongoose"

    connection = mongoose.createConnection()

    container.set "connection", connection
    container.set "mongoose", mongoose
    container.set "mongodb", mongoose.mongo

    name = container.get "name"
    connectionString = process.env.MONGOHQ_URL or "mongodb://localhost/#{name}"
    container.set "connection string", connectionString

    loader.once "configured", ->
        logger.info "loading", "mongoose"

        connectionString = container.get "connection string"
        connection.open connectionString, ->
            callback.loaded()

    callback.injected()
    callback.configured()
