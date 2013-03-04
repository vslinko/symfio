symfio = require ".."
require "should"


describe "symfio()", ->
    it "should return configured container", ->
        c = symfio "test", __dirname

        c.get("name").should.equal "test"
        c.get("silent").should.be.false

        c.get("application directory").should.equal __dirname
        c.get("fixtures directory").should.equal "#{__dirname}/fixtures"
        c.get("uploads directory").should.equal "#{__dirname}/public/uploads"
        c.get("public directory").should.equal "#{__dirname}/public"

        c.get("logger").should.be.an.instanceOf symfio.logger.Logger
        c.get("loader").should.be.an.instanceOf symfio.loader.Loader
        c.get("unloader").should.be.an.instanceOf symfio.unloader.Unloader
