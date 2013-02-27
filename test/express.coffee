fakeContainer = require "./support/fake_container"
supplier = require ".."
express = require "express"
sinon = require "sinon"
require "should"


describe "express", ->
    container = null
    sandbox = null
    app = null

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        sandbox.stub express.application, "use"

    afterEach ->
        sandbox.restore()

    it "should use bodyParser", (callback) ->
        sandbox.stub express.application, "defaultConfiguration"

        supplier.plugins.express container, ->
            use = express.application.use
            use.calledOnce.should.be.true
            use.firstCall.args[0].name.should.equal "bodyParser"
            callback()

    it "should use errorHandler in development environment", (callback) ->
        nodeEnv = process.env.NODE_ENV
        process.env.NODE_ENV = "development"

        supplier.plugins.express container, ->
            use = express.application.use
            use.lastCall.args[0].name.should.equal "errorHandler"

            process.env.NODE_ENV = nodeEnv
            callback()
