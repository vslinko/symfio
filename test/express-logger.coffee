containerTest = require "./support/container_test"
express       = require "express"
symfio        = require ".."
require "should"

describe "symfio.plugins.expressLogger()", ->
  wrapper = containerTest ->
    @stub express.logger, "format"
    @format = express.logger.format

    @container.set "express", express
    @container.set "app", express()

  beforeEach wrapper.loader()
  afterEach wrapper.unloader()

  it "should log requests", wrapper.wrap ->
    req = method: "GET", originalUrl: "/", _startTime: new Date
    res = statusCode: 200

    symfio.plugins.expressLogger @container, =>
      @format.calledOnce.should.be.true
      formatter = @format.firstCall.args[1]
      formatter [], req, res
      @logger.info.calledTwice.should.be.true
      @logger.info.lastCall.args[0].should.equal "GET /"
      @logger.info.lastCall.args[1].should.match /^200 \d+ms$/
      @logger.info.lastCall.args[2].should.equal "express"
