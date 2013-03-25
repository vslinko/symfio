symfio = require "../.."
require "should"


describe "bower", ->
  test = symfio.test.example require "../../examples/bower"

  before test.before()
  after test.after()

  describe "GET /components/jquery/jquery.js", ->
    it "should respond with installed components", test.wrap (callback) ->
      req = @get "/components/jquery/jquery.js"
      req.end (err, res) ->
        res.should.have.status 200
        res.text.should.include "jQuery"
        callback()
