exampleTest = require "../support/example_test"
require "should"


describe "auth", ->
    wrapper = exampleTest "auth"

    before wrapper.loader()
    after wrapper.unloader()

    describe "POST /sessions", ->
        it "should authenticate user", wrapper.wrap (callback) ->
            req = @post "/sessions"
            req.send username: "username", password: "password"
            req.end (err, res) =>
                res.should.have.status 201
                res.should.be.json
                res.body.should.have.property "token"
                token = res.body.token

                req = @get "/"
                req.set "Authorization", "Token #{token}"
                req.end (err, res) ->
                    res.should.have.status 200
                    res.should.be.json
                    res.body.should.have.property "user"
                    callback()

        it "should respond with 401 if user not found",
            wrapper.wrap (callback) ->
                req = @post "/sessions"
                req.send username: "notfound", password: "password"
                req.end (err, res) ->
                    res.should.have.status 401
                    callback()

        it "should respond with 401 if password is invalid",
            wrapper.wrap (callback) ->
                req = @post "/sessions"
                req.send username: "username", password: "invalid"
                req.end (err, res) ->
                    res.should.have.status 401
                    callback()
