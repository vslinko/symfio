supplier = require ".."
require "should"


describe "Container", ->
    it "should contain configuration", ->
        container = new supplier.container.Container
        container.set "foo", "bar"
        container.get("foo").should.equal "bar"

    it "should emit event when value is changed", (callback) ->
        container = new supplier.container.Container
        container.set "test value", "previous"
        
        container.once "changed test value", (value, previousValue) ->
            value.should.equal "new"
            previousValue.should.equal "previous"
            callback()

        container.set "test value", "new"

    it "should return default value if value is undefined", ->
        container = new supplier.container.Container
        container.get("undefined", "default").should.equal "default"
        container.set "undefined", false
        container.get("undefined", "default").should.be.false
