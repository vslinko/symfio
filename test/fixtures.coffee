assert = require "assert"
async = require "async"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Fixtures plugin", ->
    supply = null

    createSupplier = ->
        supply = supplier()
        supply.set "connection string", "mongodb://localhost/test"
        supply.set "fixtures directory", path.join __dirname, "fixtures"
        supply.use supplier.plugins.mongoose
        supply.use supplier.plugins.fixtures

    beforeEach (callback) ->
        createSupplier()
        callback()

    afterEach (callback) ->
        connection = supply.get "connection"
        connection.db.dropDatabase ->
            callback()

    it "should load fixtures only if collection is empty", (callback) ->
        testCount = (callback) ->
            supply.on "loaded", ->
                connection = supply.get "connection"
                collection = connection.db.collection "test"
                collection.count (err, count) ->
                    assert.equal 3, count
                    callback()

        async.waterfall [
            (callback) ->
                testCount callback

            (callback) ->
                createSupplier()
                testCount callback
        ], callback
