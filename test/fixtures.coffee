cleaner = require "./utils/cleaner"
assert = require "assert"
async = require "async"
path = require "path"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Fixtures plugin", ->
    container = null
    loader = null
    Test = null

    createSupplier = (callback) ->
        container = supplier "test", __dirname
        container.set "silent", true
        loader = container.get "loader"

        loader.use supplier.plugins.mongoose
        loader.use (container, callback) ->
            connection = container.get "connection"
            mongoose = container.get "mongoose"

            TestSchema = new mongoose.Schema {
                name: type: String, required: true
                hooked: type: Boolean, default: false
            }, safe: true

            TestSchema.pre "save", (callback) ->
                @hooked = true
                callback()

            Test = connection.model "test", TestSchema
            callback()

        loader.use supplier.plugins.fixtures
        loader.load callback

    beforeEach (callback) ->
        createSupplier ->
            callback()

    afterEach (callback) ->
        cleaner container, [
            cleaner.mongoose
        ], callback

    it "should load fixtures only if collection is empty", (callback) ->
        testCount = (callback) ->
            Test.find (err, items) ->
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

    it "should warn if module isn't defined", (callback) ->
        container = supplier "test", __dirname
        container.set "silent", true

        logger = container.get "logger"
        logger.warn = ->
            callback()

        loader = container.get "loader"
        loader.use supplier.plugins.mongoose
        loader.use supplier.plugins.fixtures
        loader.load()
