symfio = require "../.."
require "should"


describe "fruits", ->
  test = symfio.test.example require "../../examples/fruits"

  before test.before()
  after test.after()

  describe "GET /fruits", ->
    it "should respond with sorted array with fruits",
      test.wrap (callback) ->
        req = @get "/fruits"
        req.end (err, res) ->
          res.should.have.status 200
          res.should.be.json
          res.body.should.be.array
          res.body.should.have.lengthOf 3
          res.body[0].name.should.equal "Orange"
          res.body[1].name.should.equal "Banana"
          res.body[2].name.should.equal "Apple"
          callback()
