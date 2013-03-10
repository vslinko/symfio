exampleTest = require "../support/example_test"
require "should"

describe "uploads", ->
  wrapper = exampleTest "uploads"

  before wrapper.loader()
  after wrapper.unloader()

  describe "POST /uploads", ->
    it "should upload file", wrapper.wrap (callback) ->
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
