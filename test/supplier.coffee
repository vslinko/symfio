supplier = require ".."
require "should"


describe "Supplier", ->
    it "should configure container", ->
        applicationDirectory = __dirname
        fixturesDirectory = "#{__dirname}/fixtures"
        uploadsDirectory = "#{__dirname}/public/uploads"
        publicDirectory = "#{__dirname}/public"

        c = supplier "test", applicationDirectory

        c.get("name").should.equal "test"
        c.get("silent").should.be.false

        c.get("application directory").should.equal applicationDirectory
        c.get("fixtures directory").should.equal fixturesDirectory
        c.get("uploads directory").should.equal uploadsDirectory
        c.get("public directory").should.equal publicDirectory

        c.get("logger").should.be.an.instanceOf supplier.logger.Logger
        c.get("loader").should.be.an.instanceOf supplier.loader.Loader
        c.get("unloader").should.be.an.instanceOf supplier.unloader.Unloader
