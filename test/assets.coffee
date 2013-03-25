express = require "express"
symfio  = require ".."
require "should"

describe "symfio.plugins.assets()", ->
  test = symfio.test.plugin ->
    app = express()

    @stub app, "use"

    @container.set "public directory", __dirname
    @container.set "app", app

  beforeEach test.beforeEach()
  afterEach test.afterEach()

  it "should output message", test.wrap ->
    symfio.plugins.assets @container, ->
    @logger.info.calledOnce.should.be.true
    @logger.info.firstCall.args[0].should.equal "loading plugin"
    @logger.info.firstCall.args[1].should.equal "assets"
