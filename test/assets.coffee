containerTest = require "./support/container_test"
symfio = require ".."
express = require "express"
require "should"


describe "symfio.plugins.assets()", ->
    wrapper = containerTest ->
        app = express()

        @stub app, "use"

        @container.set "public directory", __dirname
        @container.set "app", app

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should output message", wrapper.wrap ->
        symfio.plugins.assets @container, ->
        @logger.info.calledOnce.should.be.true
        @logger.info.firstCall.args[0].should.equal "loading plugin"
        @logger.info.firstCall.args[1].should.equal "assets"
