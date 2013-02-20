assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "CRUD plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.use supplier.plugins.crud

    it "should inject crud", (callback) ->
        supply.once "configured", ->
            assert.notEqual undefined, supply.get "crud"
            callback()
