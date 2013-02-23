supertest = require "supertest"
cleaner = require "./utils/cleaner"
assert = require "assert"
async = require "async"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Auth plugin", ->
    connection = null
    container = null
    mongoose = null
    test = null
    User = null

    beforeEach (callback) ->
        container = supplier "test", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.auth
        loader.use supplier.plugins.express
        loader.use supplier.plugins.mongoose

        loader.once "loaded", ->
            connection = container.get "connection"
            mongoose = container.get "mongoose"
            app = container.get "app"

            app.get "/test", (req, res) ->
                res.send if req.user then data: "test" else 401

            test = supertest app

            User = connection.model "users"
            user = new User
                username: "test"
                password: "test"
            user.save ->
                callback()

    afterEach (callback) ->
        cleaner container, [
            cleaner.express
            cleaner.mongoose
        ], callback

    it "should create user", (callback) ->
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
                        assert.equal user.tokens[0].hash, res.body.token
                        callback null, res.body.token

            (token, callback) ->
                req = test.get "/test"
                req.set "Authorization", "Token #{token}"
                req.end (err, res) ->
                    assert.equal "test", res.body.data
                    callback()
        ], callback

    it "should expire tokens", (callback) ->
        async.waterfall [
            (callback) ->
                req = test.post "/sessions"
                req.send username: "test", password: "test"
                req.end (err, res) ->
                    User.findOne username: "test", (err, user) ->
                        assert.equal user.tokens[0].hash, res.body.token
                        user.tokens[0].expires = new Date Date.now() - 1
                        user.save ->
                            callback null, res.body.token

            (token, callback) ->
                req = test.get "/test"
                req.set "Authorization", "Token #{token}"
                req.end (err, res) ->
                    assert.equal 401, res.status
                    callback()
        ], callback

    it "should return 500 http code when mongo failed", (callback) ->
        findOne = mongoose.Query.prototype.findOne
        mongoose.Query.prototype.findOne = (query, callback) ->
            callback new Error

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
