symfio = require ".."
require "should"

describe "symfio()", ->
  it "should return configured container", ->
    container = symfio "test", __dirname

    container.get("name").should.eql "test"
    container.get("silent").should.be.false
    container.get("application directory").should.eql __dirname

    container.get("logger").should.be.an.instanceOf symfio.logger.Logger
    container.get("loader").should.be.an.instanceOf symfio.loader.Loader
    container.get("unloader").should.be.an.instanceOf symfio.unloader.Unloader
