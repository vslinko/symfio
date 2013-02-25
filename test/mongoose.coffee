cleaner = require "./utils/cleaner"
assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Mongoose plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier "test", __dirname
        container.set "silent", true
        loader = container.get "loader"
        loader.use supplier.plugins.mongoose

    afterEach (callback) ->
        cleaner container, [
            cleaner.mongoose
        ], callback

    it "should inject some values", (callback) ->
        loader.load ->
            assert.ok container.get "connection"
            assert.ok container.get "mongoose"
            assert.ok container.get "mongodb"
            callback()

    it "should generate connection string using name value", (callback) ->
        loader.load ->
            connection = container.get "connection"
            assert.equal "localhost", connection.host
            assert.equal 27017, connection.port
            assert.equal undefined, connection.user
            assert.equal undefined, connection.pass
            assert.equal "test", connection.name
            callback()

    it "should inject MONGOHQ_URL to connection string", (callback) ->
        process.env.MONGOHQ_URL = "mongodb://127.0.0.1/abra-kadabra"

        container = supplier "test", __dirname
        container.set "silent", true
        loader = container.get "loader"

        loader.use supplier.plugins.mongoose

        loader.load ->
            connection = container.get "connection"
            assert.equal "127.0.0.1", connection.host
            assert.equal "abra-kadabra", connection.name
            callback()

    it "should connect to database", (callback) ->
        loader.load ->
            connection = container.get "connection"
            assert.equal 1, connection.readyState
            callback()
