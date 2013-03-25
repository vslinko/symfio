express = require "express"
symfio  = require ".."
require "should"

describe "symfio.plugins.express()", ->
  test = symfio.test.plugin ->
    @stub express.application, "use"
    @use = express.application.use

  beforeEach test.beforeEach()
  afterEach test.afterEach()

  it "should use bodyParser", test.wrap ->
    @stub express.application, "defaultConfiguration"
    symfio.plugins.express @container, ->
    @use.calledOnce.should.be.true
    @use.firstCall.args[0].name.should.equal "bodyParser"

  it "should use errorHandler in development environment", test.wrap ->
    nodeEnv              = process.env.NODE_ENV
    process.env.NODE_ENV = "development"

    symfio.plugins.express @container, ->
    @use.lastCall.args[0].name.should.equal "errorHandler"

    process.env.NODE_ENV = nodeEnv
