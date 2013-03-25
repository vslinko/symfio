symfio = require "../.."
require "should"


describe "uploads", ->
  test = symfio.test.example require "../../examples/uploads"

  before test.before()
  after test.after()

  describe "POST /uploads", ->
    it "should upload file", test.wrap (callback) ->
      req = @post "/uploads"
      req.attach "file", __filename
      req.end (err, res) =>
        res.should.have.status 201
        res.should.have.header "Location"

        req = @get res.headers.location
        req.end (err, res) ->
          res.should.have.status 200
          res.text.should.include "Super Unique Message"

          callback()
