example = require "../support/example"
require "should"


describe "Auth example", ->
    test = unloader = null
    
    before (callback) ->
        example "auth", ->
            [test, unloader] = arguments
            callback()

    after (callback) ->
        unloader.unload callback

    it "should authenticate and populate user", (callback) ->
        req = test.post "/sessions"
        req.send username: "username", password: "password"
        req.end (err, res) ->
            res.should.have.status 201
            res.should.be.json
            res.body.should.have.property "token"
            token = res.body.token

            req = test.get "/"
            req.set "Authorization", "Token #{token}"
            req.end (err, res) ->
                res.should.have.status 200
                res.should.be.json
                res.body.should.have.property "user"
                callback()

    it "should return 401 status code when user not found", (callback) ->
        req = test.post "/sessions"
        req.send username: "notfound", password: "password"
        req.end (err, res) ->
            res.should.have.status 401
            callback()

    it "should return 401 status code when password is invalid", (callback) ->
        req = test.post "/sessions"
        req.send username: "username", password: "invalid"
        req.end (err, res) ->
            res.should.have.status 401
            callback()
