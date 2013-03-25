symfio = require "../.."
require "should"


describe "auth", ->
  test = symfio.test.example require "../../examples/auth"

  before test.before()
  after test.after()

  describe "POST /sessions", ->
    it "should authenticate user", test.wrap (callback) ->
      req = @post "/sessions"
      req.send username: "username", password: "password"
      req.end (err, res) =>
        res.should.have.status 201
        res.should.be.json
        res.body.should.have.property "token"

        req = @get "/"
        req.set "Authorization", "Token #{res.body.token}"
        req.end (err, res) ->
          res.should.have.status 200
          res.should.be.json
          res.body.should.have.property "user"
          callback()

    it "should respond with 401 if user not found", test.wrap (callback) ->
      req = @post "/sessions"
      req.send username: "notfound", password: "password"
      req.end (err, res) ->
        res.should.have.status 401
        callback()

    it "should respond with 401 if password is invalid",
      test.wrap (callback) ->
        req = @post "/sessions"
        req.send username: "username", password: "invalid"
        req.end (err, res) ->
          res.should.have.status 401
          callback()
