containerTest = require "./support/container_test"
symfio        = require ".."
mongoose      = require "mongoose"
require "should"

describe "symfio.plugins.mongoose()", ->
  wrapper = containerTest ->
    @stub mongoose.Connection.prototype, "open"
    @open = mongoose.Connection.prototype.open

  beforeEach wrapper.loader()
  afterEach wrapper.unloader()

  it "should generate connection string using name value", wrapper.wrap ->
    symfio.plugins.mongoose @container, ->
    @open.calledOnce.should.be.true
    @open.firstCall.args[0].should.equal "mongodb://localhost/symfio"

  it "should use MONGOHQ_URL as connection string", wrapper.wrap ->
    mongohqUrl              = process.env.MONGOHQ_URL
    process.env.MONGOHQ_URL = "mongodb://127.0.0.1/abra-kadabra"

    symfio.plugins.mongoose @container, ->
    @open.calledOnce.should.be.true
    @open.firstCall.args[0].should.equal process.env.MONGOHQ_URL

    process.env.MONGOHQ_URL = mongohqUrl
