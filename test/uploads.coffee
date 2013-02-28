fakeContainer = require "./support/fake_container"
supplier = require ".."
express = require "express"
errors = require "../lib/supplier/errors"
sinon = require "sinon"
require "should"


describe "uploads", ->
    container = null
    sandbox = null
    logger = null
    app = null

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        container.set "public directory", __dirname
        container.set "uploads directory", __dirname

        app = express()
        sandbox.spy app, "use"
        container.set "app", app

    afterEach ->
        sandbox.restore()

    it "should catch only POST /uploads", (callback) ->
        supplier.plugins.uploads container, ->
            middleware = app.use.firstCall.args[0]

            req = url: "/", method: "GET"
            middleware req, null, callback

    it "should return 400 http code when no file sent", ->
        supplier.plugins.uploads container, ->
            middleware = app.use.firstCall.args[0]

            req = url: "/uploads", method: "POST", body: [], files: []
            res = send: sinon.spy()
            middleware req, res, ->
            res.send.calledOnce.should.be.true
            res.send.firstCall.args[0].should.equal 400

    it "should exit if uploads directory not in public directory", ->
        container.set "public directory", "/a"
        container.set "uploads directory", "/b"
        
        supplier.plugins.uploads container

        e = container.get("logger").error
        e.calledOnce.should.be.true
        e.firstCall.args[0].should.eql errors.UPLOAD_DIRECTORY_IS_NOT_PUBLIC
