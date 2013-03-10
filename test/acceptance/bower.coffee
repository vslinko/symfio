exampleTest = require "../support/example_test"
require "should"

describe "bower", ->
  wrapper = exampleTest "bower"

  before wrapper.loader()
  after wrapper.unloader()

  describe "GET /components/jquery/jquery.js", ->
    it "should respond with installed components", wrapper.wrap (callback) ->
      req = @get "/components/jquery/jquery.js"
      req.end (err, res) ->
        res.should.have.status 200
        res.text.should.include "jQuery"
        callback()
