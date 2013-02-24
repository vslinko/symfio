assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Container", ->
    it "should contain configuration", ->
        container = new supplier.container.Container
        container.set "foo", "bar"
        assert.equal "bar", container.get "foo"

    it "should emit event when value is changed", (callback) ->
        container = new supplier.container.Container
        container.set "test value", "previous"
        
        container.once "changed test value", (value, previousValue) ->
            assert.equal "new", value
            assert.equal "previous", previousValue
            callback()

        container.set "test value", "new"
