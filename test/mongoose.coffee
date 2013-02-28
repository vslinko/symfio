fakeContainer = require "./support/fake_container"
supplier = require ".."
mongoose = require "mongoose"
sinon = require "sinon"
require "should"


describe "mongoose", ->
    container = null
    sandbox = null

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        sandbox.stub mongoose.Connection.prototype, "open"
        mongoose.Connection.prototype.open.yields()

    afterEach ->
        sandbox.restore()

    it "should generate connection string using name value", ->
        supplier.plugins.mongoose container, ->
            open = mongoose.Connection.prototype.open
            open.calledOnce.should.be.true
            open.args[0][0].should.equal "mongodb://localhost/supplier"

    it "should use MONGOHQ_URL as connection string", ->
        process.env.MONGOHQ_URL = "mongodb://127.0.0.1/abra-kadabra"

        supplier.plugins.mongoose container, ->
            open = mongoose.Connection.prototype.open
            open.calledOnce.should.be.true
            open.args[0][0].should.equal process.env.MONGOHQ_URL
