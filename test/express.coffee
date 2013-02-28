containerTest = require "./support/container_test"
supplier = require ".."
express = require "express"
require "should"


describe "supplier.plugins.express()", ->
    wrapper = containerTest ->
        @stub express.application, "use"
        @use = express.application.use

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should use bodyParser", wrapper.wrap ->
        @stub express.application, "defaultConfiguration"
        supplier.plugins.express @container, ->
        @use.calledOnce.should.be.true
        @use.firstCall.args[0].name.should.equal "bodyParser"

    it "should use errorHandler in development environment", wrapper.wrap ->
        nodeEnv = process.env.NODE_ENV
        process.env.NODE_ENV = "development"

        supplier.plugins.express @container, ->
        @use.lastCall.args[0].name.should.equal "errorHandler"

        process.env.NODE_ENV = nodeEnv
