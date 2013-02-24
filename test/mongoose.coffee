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
        loader.once "injected", ->
            assert.ok container.get "connection"
            assert.ok container.get "mongoose"
            assert.ok container.get "mongodb"
            connectionString = container.get "connection string"
            assert.equal "mongodb://localhost/test", connectionString
            callback()

    it "should connect to database", (callback) ->
        loader.once "loaded", ->
            connection = container.get "connection"
            assert.equal 1, connection.readyState
            callback()

    it "should inject MONGOHQ_URL to connection string", (callback) ->
        process.env.MONGOHQ_URL = "hello world"

        container = supplier "test", __dirname
        container.set "silent", true
        loader = container.get "loader"

        loader.use supplier.plugins.mongoose

        loader.once "injected", ->
            connectionString = container.get "connection string"
            assert.equal process.env.MONGOHQ_URL, connectionString
            callback()
