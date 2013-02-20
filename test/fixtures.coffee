assert = require "assert"
async = require "async"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Fixtures plugin", ->
    container = null
    loader = null
    model = null

    createSupplier = (callback) ->
        container = supplier()
        loader = container.get "loader"
        
        container.set "connection string", "mongodb://localhost/test"
        container.set "fixtures directory", path.join __dirname, "fixtures"
        loader.use supplier.plugins.mongoose
        loader.use supplier.plugins.fixtures

        loader.once "injected", ->
            connection = container.get "connection"
            mongoose = container.get "mongoose"

            TestSchema = new mongoose.Schema {
                name: type: String, required: true
                hooked: type: Boolean, default: false
            }, safe: true

            TestSchema.pre "save", (callback) ->
                @hooked = true
                callback()

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
            loader.once "loaded", ->
                model.find (err, items) ->
                    assert.equal 3, items.length
                    
                    items.forEach (item) ->
                        assert.ok item.hooked
                    
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

        container = supplier()
        loader = container.get "loader"

        container.set "connection string", "mongodb://localhost/test"
        container.set "fixtures directory", path.join __dirname, "fixtures"
        loader.use supplier.plugins.mongoose

        loader.once "loaded", ->
            loader.use supplier.plugins.fixtures
            loader.once "configured", ->
                callback()
