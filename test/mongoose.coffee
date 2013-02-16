assert = require "assert"

supplier = require "../lib/supplier"


describe "Mongoose plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.set "connection string", "mongodb://localhost/test"
        supply.use supplier.plugins.mongoose

    afterEach (callback) ->
        connection = supply.get "connection"
        connection.close ->
            callback()

    it "should inject connection, mongoose, and mongodb", (callback) ->
        supply.on "configured", ->
            assert.notEqual undefined, supply.get "connection"
            assert.notEqual undefined, supply.get "mongoose"
            assert.notEqual undefined, supply.get "mongodb"
            callback()

    it "should connect to database", (callback) ->
        supply.on "loaded", ->
            connection = supply.get "connection"
            assert.equal 1, connection.readyState
            callback()
