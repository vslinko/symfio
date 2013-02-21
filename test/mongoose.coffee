assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Mongoose plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier "test", __dirname
        loader = container.get "loader"

        loader.use supplier.plugins.mongoose

    afterEach ->
        connection = container.get "connection"
        connection.close ->

    it "should inject connection, mongoose, mongodb, and connection string", (callback) ->
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

    it "should inject connection string from process.env.MONGOHQ_URL", (callback) ->
        process.env.MONGOHQ_URL = "hello world"

        container = supplier "test", __dirname
        loader = container.get "loader"

        loader.use supplier.plugins.mongoose
        loader.once "injected", ->
            assert.equal process.env.MONGOHQ_URL, container.get "connection string"
            callback()
