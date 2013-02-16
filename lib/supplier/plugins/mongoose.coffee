mongoose = require "mongoose"


module.exports = (supply, callback) ->
    connection = mongoose.createConnection()

    supply.set "connection", connection
    supply.set "mongoose", mongoose
    supply.set "mongodb", mongoose.mongo

    if not supply.get("connection string") and process.env.MONGOHQ_URL
        supply.set "connection string", process.env.MONGOHQ_URL

    supply.on "configured", ->
        connectionString = supply.get "connection string"

        connection.open connectionString, ->
            callback.loaded()

    callback.configured()
