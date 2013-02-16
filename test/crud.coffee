assert = require "assert"

supplier = require "../lib/supplier"


describe "CRUD plugin", ->
    supply = null

    beforeEach ->
        supply = supplier()
        supply.use supplier.plugins.crud

    it "should inject crud", (callback) ->
        supply.on "configured", ->
            assert.notEqual undefined, supply.get "crud"
            callback()
