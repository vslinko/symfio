json     = require "json-output"
request = require "supertest"
assert = require "assert"
crypto = require "crypto"

supplier = require if process.env.COVERAGE \
    then "../lib-cov/supplier"
    else "../lib/supplier"


describe "Auth plugin", ->
    container = null
    loader = null
    User = null
    
    beforeEach (callback) ->
        container = supplier "test", __dirname
        loader = container.get "loader"
        loader.use supplier.plugins.express
        loader.use supplier.plugins.mongoose
        loader.use supplier.plugins.auth

        loader.once "loaded", ->
            app = container.get "app"
            connection = container.get "connection"

            app.get "/test", (req, res) ->
                if req.user
                    res.json data: "test"
                else
                    res.send 401

            User = connection.model "users"

            user = new User
                username: "test"
                password: "test"
            
            user.save ->
                callback()
        
    afterEach (callback) ->
        User.remove ->
            server = container.get "server"
            try
                server.close callback
            catch err
                callback()

    it "should create user with salt and secure password", (callback) ->
        User.findOne username: "test", (err, user) ->
            assert.ok user?
            assert.ok user.salt?
            assert.equal user.password, crypto.createHash("sha256")
                .update("test" + user.salt, "utf8")
                .digest "hex"
            callback()

    it "should created user not authenticated", (callback) ->
        User.findOne username: "test", (err, user) ->
            assert.equal 0, user.tokens.length
            callback()

    it "should create, authenticate and populate user", (callback) ->
        app = container.get "app"
        request(app)
            .post("/auth-token")
            .send(username: "test", password: "test")
            .end (err, res) ->
                User.findOne username: "test", (err, user) ->
                    assert.equal user.tokens[0].token, res.body.authToken

                    request(app)
                        .get("/test")
                        .set("Authorization", "Token #{res.body.authToken}")
                        .end (err, res) ->
                            assert.equal "test", res.body.data
                            callback()
