symfio = require "../index"
chai = require "chai"


chai.use require "chai-as-promised"
chai.should()


describe "symfio()", ->
  it "should return configured container", (callback) ->
    container = symfio "test", __dirname

    container.get([
      "name"
      "applicationDirectory"
      "loader"
      "unloader"
    ]).then (dependencies) ->
      dependencies[0].should.equal "test"
      dependencies[1].should.equal __dirname
      dependencies[2].should.be.instanceOf symfio.loader.Loader
      dependencies[3].should.be.instanceOf symfio.unloader.Unloader
    .should.notify callback
