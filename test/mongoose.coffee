assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Mongoose plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.set "connection string", "mongodb://localhost/test"
        supply.use supplier.plugins.mongoose

    afterEach ->
        connection = supply.get "connection"
        connection.close ->

    it "should inject connection, mongoose, and mongodb", (callback) ->
        supply.once "configured", ->
            assert.notEqual undefined, supply.get "connection"
            assert.notEqual undefined, supply.get "mongoose"
            assert.notEqual undefined, supply.get "mongodb"
            callback()

    it "should connect to database", (callback) ->
        supply.once "loaded", ->
            connection = supply.get "connection"
            assert.equal 1, connection.readyState
            callback()

    it "should inject connection string from process.env.MONGOHQ_URL", (callback) ->
        process.env.MONGOHQ_URL = "hello world"
        supply = supplier()
        supply.use supplier.plugins.mongoose
        supply.once "configured", ->
            assert process.env.MONGOHQ_URL, supply.get "connection string"
            callback()
