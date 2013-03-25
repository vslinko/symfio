fileupload = require "fileupload"
symfio     = require ".."
express    = require "express"
errors     = require "../lib/symfio/errors"
require "should"

describe "symfio.plugins.uploads()", ->
  test = symfio.test.plugin ->
    @app = express()

    @stub @app, "use"

    @container.set "public directory", __dirname
    @container.set "uploads directory", __dirname
    @container.set "app", @app

  beforeEach test.beforeEach()
  afterEach test.afterEach()

  it "should catch only POST /uploads", test.wrap ->
    callback = @stub()
    req      = url: "/", method: "GET"

    symfio.plugins.uploads @container, ->
    middleware = @app.use.firstCall.args[0]
    middleware req, null, callback
    callback.calledOnce.should.be.true

  it "should respond with 400 if no file sent", test.wrap ->
    req = url: "/uploads", method: "POST", body: [], files: []
    res = send: @stub()

    symfio.plugins.uploads @container, ->
    middleware = @app.use.firstCall.args[0]
    middleware req, res, ->
    res.send.calledOnce.should.be.true
    res.send.firstCall.args[0].should.equal 400

  it "should exit if uploads directory not in public directory", test.wrap ->
    error = @logger.error

    @container.set "public directory", "/a"
    @container.set "uploads directory", "/b"

    symfio.plugins.uploads @container
    error.calledOnce.should.be.true
    error.firstCall.args[0].should.eql errors.UPLOAD_DIRECTORY_IS_NOT_PUBLIC

  it "should return filepath with uploads in public", test.wrap ->
    file = file: [path: "p/", basename: "f.jpg"]
    req  = url: "/uploads", method: "POST", body: [], files: file
    res  = send: @stub(), set: @stub()
    
    @stub fileupload, "createFileUpload"
    fileupload.createFileUpload.returns middleware: (req, res, callback) ->
      req.body = file
      callback()

    @container.set "public directory", "/a"
    @container.set "uploads directory", "/a/b"

    symfio.plugins.uploads @container, ->
    middleware = @app.use.firstCall.args[0]
    middleware req, res, ->
    res.set.withArgs("Location").firstCall.args[1].should.eql "/b/p/f.jpg"
