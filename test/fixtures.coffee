assert = require "assert"
async = require "async"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Fixtures plugin", ->
    supply = null
    model = null

    createSupplier = (callback) ->
        supply = supplier()
        supply.set "connection string", "mongodb://localhost/test"
        supply.set "fixtures directory", path.join __dirname, "fixtures"
        supply.use supplier.plugins.mongoose
        supply.use supplier.plugins.fixtures

        supply.once "injected", ->
            connection = supply.get "connection"
            mongoose = supply.get "mongoose"

            TestSchema = new mongoose.Schema {
                name: type: "string", required: true
                pre_save: type: Boolean, default: false
            }, safe: true

            TestSchema.pre "save", (next) ->
                @pre_save = true
                next()

            model = connection.model "test", TestSchema
            callback()

    beforeEach (callback) ->
        createSupplier ->
            model.remove ->
                callback()

    afterEach (callback) ->
        model.remove ->
            callback()

    it "should load fixtures only if collection is empty", (callback) ->
        testCount = (callback) ->
            supply.once "loaded", ->
                model.find (err, items) ->
                    assert.equal 3, items.length
                    
                    items.forEach (item) ->
                        assert.ok item.pre_save
                    callback()

        async.waterfall [
            (callback) ->
                testCount callback

            (callback) ->
                createSupplier ->
                    testCount callback
        ], callback

    it "should load fixtures immediately after connected to database", (callback) ->
        return callback() unless process.env.COVERAGE

        supply = supplier()
        supply.set "connection string", "mongodb://localhost/test"
        supply.set "fixtures directory", path.join __dirname, "fixtures"
        supply.use supplier.plugins.mongoose

        supply.once "loaded", ->
            supply.use supplier.plugins.fixtures
            supply.once "configured", ->
                callback()
