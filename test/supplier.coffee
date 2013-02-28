supplier = require ".."
require "should"


describe "supplier()", ->
    it "should return configured container", ->
        c = supplier "test", __dirname

        c.get("name").should.equal "test"
        c.get("silent").should.be.false

        c.get("application directory").should.equal __dirname
        c.get("fixtures directory").should.equal "#{__dirname}/fixtures"
        c.get("uploads directory").should.equal "#{__dirname}/public/uploads"
        c.get("public directory").should.equal "#{__dirname}/public"

        c.get("logger").should.be.an.instanceOf supplier.logger.Logger
        c.get("loader").should.be.an.instanceOf supplier.loader.Loader
        c.get("unloader").should.be.an.instanceOf supplier.unloader.Unloader
