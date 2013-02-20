# Connect to MongoDB
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.mongoose
#     supply.set "connection string", "mongodb://localhost/test"
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
module.exports = (supply, callback) ->
    supply.info "injecting", "mongoose"

    connection = mongoose.createConnection()

    supply.set "connection", connection
    supply.set "mongoose", mongoose
    supply.set "mongodb", mongoose.mongo

    if not supply.get("connection string") and process.env.MONGOHQ_URL
        supply.set "connection string", process.env.MONGOHQ_URL

    supply.once "configured", ->
        supply.info "loading", "mongoose"

        connectionString = supply.get "connection string"

        connection.open connectionString, ->
            callback.loaded()

    callback.injected()
    callback.configured()
