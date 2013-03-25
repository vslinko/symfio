mongoose = require "mongoose"
symfio   = require ".."
fs       = require "fs"
require "should"

describe "symfio.plugins.fixtures()", ->
  test = symfio.test.plugin ->
    @model           = ->
    @model.count     = @stub()
    @model.prototype = save: @stub()

    @users = [
      {username: "username", password: "password"}
      {username: "username", password: "password"}
      {username: "username", password: "password"}
    ]

    @stub fs, "readdir"
    @stub fs, "readFile"
    @stub mongoose.Connection.prototype, "model"

    fs.readdir.yields null, ["users.json"]
    fs.readFile.yields null, JSON.stringify @users
    mongoose.Connection.prototype.model.returns @model

    @container.set "connection", new mongoose.Connection

  beforeEach test.beforeEach()
  afterEach test.afterEach()

  it "should load fixtures only if collection is empty",
    test.wrap (callback) ->
      @model.count.yields null, 0
      @model.prototype.save.yields()

      symfio.plugins.fixtures @container, =>
        @model.prototype.save.called.should.be.true
        @model.prototype.save.callCount.should.equal @users.length

        @model.prototype.save.reset()
        @model.count.yields null, 3

        symfio.plugins.fixtures @container, =>
          @model.prototype.save.called.should.be.false
          callback()

  it "should warn if mongoose module isn't defined", test.wrap (callback) ->
    mongoose.Connection.prototype.model.throws()

    symfio.plugins.fixtures @container, =>
      @logger.warn.calledOnce.should.be.true
      callback()

  it "should skip loading if json is invalid", test.wrap (callback) ->
    fs.readFile.resetBehavior()
    fs.readFile.yields null, "invalid json"

    symfio.plugins.fixtures @container, ->
      mongoose.Connection.prototype.model.called.should.be.false
      callback()
