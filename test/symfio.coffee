symfio = require ".."
chai = require "chai"


describe "symfio()", ->
  expect = chai.expect

  it "should return configured container", ->
    container = symfio "test", __dirname

    expect(container.get "name").to.equal "test"
    expect(container.get "application directory").to.equal __dirname
    expect(container.get "silent").to.be.false
    expect(container.get "logger").is.an.instanceof symfio.logger.Logger
    expect(container.get "loader").is.an.instanceof symfio.loader.Loader
    expect(container.get "unloader").is.an.instanceof symfio.unloader.Unloader
