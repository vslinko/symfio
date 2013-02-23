assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "CRUD plugin", ->
    it "should inject some values", (callback) ->
        container = supplier "test", __dirname
        loader = container.get "loader"

        loader.use supplier.plugins.crud

        loader.once "injected", ->
            assert.ok container.get "crud"
            callback()
