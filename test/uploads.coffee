containerTest = require "./support/container_test"
supplier = require ".."
express = require "express"
errors = require "../lib/supplier/errors"
require "should"


describe "supplier.plugins.uploads()", ->
    wrapper = containerTest ->
        @app = express()

        @stub @app, "use"

        @container.set "public directory", __dirname
        @container.set "uploads directory", __dirname
        @container.set "app", @app

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should catch only POST /uploads", wrapper.wrap ->
        callback = @stub()
        req = url: "/", method: "GET"

        supplier.plugins.uploads @container, ->
        middleware = @app.use.firstCall.args[0]
        middleware req, null, callback
        callback.calledOnce.should.be.true

    it "should return 400 http code when no file sent", wrapper.wrap ->
        req = url: "/uploads", method: "POST", body: [], files: []
        res = send: @stub()

        supplier.plugins.uploads @container, ->
        middleware = @app.use.firstCall.args[0]
        middleware req, res, ->
        res.send.calledOnce.should.be.true
        res.send.firstCall.args[0].should.equal 400

    it "should exit if uploads directory not in public directory",
        wrapper.wrap ->
            e = @logger.error

            @container.set "public directory", "/a"
            @container.set "uploads directory", "/b"

            supplier.plugins.uploads @container
            e.calledOnce.should.be.true
            e.firstCall.args[0].should.eql errors.UPLOAD_DIRECTORY_IS_NOT_PUBLIC
