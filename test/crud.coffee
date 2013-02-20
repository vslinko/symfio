assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "CRUD plugin", ->
    container = null
    loader = null

    beforeEach ->
        container = supplier "test", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.crud

    it "should inject crud", (callback) ->
        loader.once "injected", ->
            assert.ok container.get "crud"
            callback()
