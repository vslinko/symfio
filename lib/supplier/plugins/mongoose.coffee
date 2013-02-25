# Connect to MongoDB
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     container.set "connection string", "mongodb://localhost/test"
#     loader = container.get "loader"
#     loader.use supplier.plugins.mongoose
#     loader.load()
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
    unloader = container.get "unloader"
    loader = container.get "loader"
    logger = container.get "logger"
    name = container.get "name"

    logger.info "loading plugin", "mongoose"

    connection = mongoose.createConnection()

    container.set "connection", connection
    container.set "mongoose", mongoose
    container.set "mongodb", mongoose.mongo

    connectionString = container.get "connection string",
        process.env.MONGOHQ_URL or "mongodb://localhost/#{name}"

    connection.open connectionString, ->
        callback()

    unloader.register (callback) ->
        return callback() unless connection.readyState is 1

        connection.close ->
            callback()
