supertest = require "supertest"
assert = require "assert"
async = require "async"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Auth plugin", ->
    connection = null
    container = null
    User = null
    test = null

    beforeEach (callback) ->
        container = supplier "test", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.express
        loader.use supplier.plugins.mongoose
        loader.use supplier.plugins.auth

        loader.once "loaded", ->
            app = container.get "app"
            test = supertest app
            connection = container.get "connection"

            app.get "/test", (req, res) ->
                res.send if req.user then data: "test" else 401

            User = connection.model "users"
            User.remove ->
                user = new User
                    username: "test"
                    password: "test"

                user.save ->
                    callback()

    afterEach (callback) ->
        connection.db.dropDatabase ->
            server = container.get "server"
            connection.close ->
                try
                    server.close callback
                catch err
                    callback()

    it "should create user with salt, with secure password, and without tokens", (callback) ->
        User.findOne username: "test", (err, user) ->
            assert.ok user
            assert.ok user.salt
            assert.ok user.password
            assert.equal 0, user.tokens.length
            callback()

    it "should create, authenticate and populate user", (callback) ->
        async.waterfall [
            (callback) ->
                req = test.post "/sessions"
                req.send username: "test", password: "test"
                req.end (err, res) ->
                    User.findOne username: "test", (err, user) ->
                        assert.equal user.tokens[0].token, res.body.authToken
                        callback null, res.body.authToken

            (token, callback) ->
                req = test.get "/test"
                req.set "Authorization", "Token #{token}"
                req.end (err, res) ->
                    assert.equal "test", res.body.data
                    callback()
        ], callback

    it "should return 500 http code when mongo failed", (callback) ->
        mongoose = container.get "mongoose"
        findOne = mongoose.Query.prototype.findOne
        mongoose.Query.prototype.findOne = (query, callback) ->
            callback "error"
        
        req = test.post "/sessions"
        req.send username: "test", password: "test"
        req.end (err, res) ->
            assert.equal 500, res.status
            mongoose.Query.prototype.findOne = findOne
            callback()

    it "should return 401 http code when user not found", (callback) ->
        req = test.post "/sessions"
        req.send username: "notfound", password: "test"
        req.end (err, res) ->
            assert.equal 401, res.status
            callback()

    it "should return 401 http code when credential is invalid", (callback) ->
        req = test.post "/sessions"
        req.send username: "test", password: "invalid"
        req.end (err, res) ->
            assert.equal 401, res.status
            callback()
