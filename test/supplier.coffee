assert = require "assert"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Supplier", ->
    it "should configure container", ->
        nodeEnv = process.env.NODE_ENV
        process.env.NODE_ENV = "production"
        container = supplier()

        assert.equal "supplier", container.get "name"
        assert.equal false, container.get "silent"
        assert.ok container.get "logger"
        assert.ok container.get "loader"

        process.env.NODE_ENV = "test"
        container = supplier "test"

        assert.equal "test", container.get "name"
        assert.equal true, container.get "silent"

        process.env.NODE_ENV = nodeEnv
