containerTest = require "./support/container_test"
fileupload = require "fileupload"
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

    it "should respond with 400 if no file sent", wrapper.wrap ->
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

    it "should return filepath with uploads in public", wrapper.wrap ->
        file = file: [path: "p/", basename: "f.jpg"]
        req = url: "/uploads", method: "POST", body: [], files: file
        res = send: @stub(), set: @stub()
        
        @stub fileupload, "createFileUpload"
        fileupload.createFileUpload.returns middleware: (req, res, callback) ->
            req.body = file
            callback()

        @container.set "public directory", "/a"
        @container.set "uploads directory", "/a/b"

        supplier.plugins.uploads @container, ->
        middleware = @app.use.firstCall.args[0]
        middleware req, res, ->
        res.set.withArgs("Location").firstCall.args[1].should.eql "/b/p/f.jpg"
