mongoose = require "mongoose"
symfio   = require ".."
require "should"

describe "symfio.plugins.mongoose()", ->
  test = symfio.test.plugin ->
    @stub mongoose.Connection.prototype, "open"
    @open = mongoose.Connection.prototype.open

  beforeEach test.beforeEach()
  afterEach test.afterEach()

  it "should generate connection string using name value", test.wrap ->
    symfio.plugins.mongoose @container, ->
    @open.calledOnce.should.be.true
    @open.firstCall.args[0].should.equal "mongodb://localhost/symfio"

  it "should use MONGOHQ_URL as connection string", test.wrap ->
    mongohqUrl              = process.env.MONGOHQ_URL
    process.env.MONGOHQ_URL = "mongodb://127.0.0.1/abra-kadabra"

    symfio.plugins.mongoose @container, ->
    @open.calledOnce.should.be.true
    @open.firstCall.args[0].should.equal process.env.MONGOHQ_URL

    process.env.MONGOHQ_URL = mongohqUrl
