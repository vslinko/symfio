assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Container", ->
    it "should contain configuration", ->
        container = supplier.container()
        container.set "foo", "bar"
        assert.equal "bar", container.get "foo"
