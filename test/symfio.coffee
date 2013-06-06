symfio = require "../index"
chai = require "chai"
w = require "when"


describe "symfio()", ->
  chai.use require "chai-as-promised"
  chai.should()

  it "should return configured container", (callback) ->
    container = symfio "test", __dirname

    w.all([
      container.get("name")
      container.get("application directory")
      container.get("silent")
      container.get("loader")
      container.get("unloader")
    ]).then (dependencies) ->
      dependencies[0].should.equal "test"
      dependencies[1].should.equal __dirname
      dependencies[2].should.be.false
      dependencies[3].should.be.instanceOf symfio.loader.Loader
      dependencies[4].should.be.instanceOf symfio.unloader.Unloader
    .should.notify callback
