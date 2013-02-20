# Connect to MongoDB
#
#     supplier = require "supplier"
#     container = supplier()
#     container.set "connection string", "mongodb://localhost/test"
#     loader = container.get "loader"
#     loader.use supplier.plugins.mongoose
mongoose = require "mongoose"


#### Required configuration:
#
# * __connection string__ — MongoDB connection string.
#
#### Provides:
#
# * __connection__ — Mongoose connection instance.
# * __mongoose__ — `mongoose` module.
# * __mongodb__ — `mongodb` module.
#
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "injecting", "mongoose"

    connection = mongoose.createConnection()

    container.set "connection", connection
    container.set "mongoose", mongoose
    container.set "mongodb", mongoose.mongo

    if not container.get("connection string") and process.env.MONGOHQ_URL
        container.set "connection string", process.env.MONGOHQ_URL

    loader.once "configured", ->
        logger.info "loading", "mongoose"

        connectionString = container.get "connection string"

        connection.open connectionString, ->
            callback.loaded()

    callback.injected()
    callback.configured()
