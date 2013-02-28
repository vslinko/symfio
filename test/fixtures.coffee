fakeContainer = require "./support/fake_container"
supplier = require ".."
mongoose = require "mongoose"
sinon = require "sinon"
fs = require "fs"
require "should"


describe "fixtures", ->
    container = null
    sandbox = null
    model = null
    app = null

    users = [
        {username: "username", password: "password"}
        {username: "username", password: "password"}
        {username: "username", password: "password"}
    ]

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        sandbox.stub fs, "readdir"
        fs.readdir.yields null, ["users.json"]

        sandbox.stub fs, "readFile"
        fs.readFile.yields null, JSON.stringify users

        model = ->
        sandbox.stub mongoose.Connection.prototype, "model"
        mongoose.Connection.prototype.model.returns model
        container.set "connection", new mongoose.Connection

    afterEach ->
        sandbox.restore()

    it "should load fixtures only if collection is empty", (callback) ->
        model.count = sinon.stub()
        model.count.yields null, 0

        model.prototype = save: sinon.stub()
        model.prototype.save.yields()

        supplier.plugins.fixtures container, ->
            model.prototype.save.called.should.be.true
            model.prototype.save.callCount.should.equal users.length

            model.prototype.save.reset()
            model.count.yields null, 3

            supplier.plugins.fixtures container, ->
                model.prototype.save.called.should.be.false
                callback()

    it "should warn if module isn't defined", (callback) ->
        logger = container.get "logger"
        mongoose.Connection.prototype.model.throws()

        supplier.plugins.fixtures container, ->
            logger.warn.calledOnce.should.be.true
            callback()

    it "should skip loading if json is invalid", (callback) ->
        fs.readFile.resetBehavior()
        fs.readFile.yields null, "invalid json"

        supplier.plugins.fixtures container, ->
            mongoose.Connection.prototype.model.called.should.be.false
            callback()
