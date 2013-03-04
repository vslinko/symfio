containerTest = require "./support/container_test"
mongoose = require "mongoose"
symfio = require ".."
express = require "express"
require "should"


describe "symfio.plugins.auth()", ->
    wrapper = containerTest ->
        @tokenHash = "tokenHash"
        @app = express()
        @req = get: @stub().returns "Token #{@tokenHash}"
        @res = send: @stub()

        @stub mongoose.Model, "findOne"
        @stub mongoose.Connection.prototype, "model"
        @stub @app, "use"

        mongoose.Connection.prototype.model.returns mongoose.Model

        @container.set "connection", new mongoose.Connection
        @container.set "mongoose", mongoose
        @container.set "app", @app

    beforeEach wrapper.loader()
    afterEach wrapper.unloader()

    it "should populate user in request object", wrapper.wrap ->
        user = username: "username", tokens: [
            hash: @tokenHash, expires: new Date Date.now() + 10000
        ]

        mongoose.Model.findOne.yields null, user
        symfio.plugins.auth @container, ->
        populateMiddleware = @app.use.firstCall.args[0]
        populateMiddleware @req, null, ->
        @req.should.have.property "user"
        @req.user.username.should.equal user.username
        @req.user.token.hash.should.equal @tokenHash

    it "shouldn't populate user if token is expired", wrapper.wrap ->
        user = username: "nameuser", tokens: [
            hash: "tokenHash", expires: new Date Date.now() - 10000
        ]

        mongoose.Model.findOne.yields null, user
        symfio.plugins.auth @container, ->
        populateMiddleware = @app.use.firstCall.args[0]
        populateMiddleware @req, null, ->
        @req.should.not.have.property "user"

    it "should respond with 500 if mongodb request is failed", wrapper.wrap ->
        @req.url = "/sessions"
        @req.method = "POST"
        @req.body = username: "username"

        mongoose.Model.findOne.yields new Error
        symfio.plugins.auth @container, ->
        authenticateMiddleware = @app.use.lastCall.args[0]
        authenticateMiddleware @req, @res, ->
        @res.send.calledOnce.should.be.true
        @res.send.firstCall.args[0].should.equal 500

    it "should respond with 200 if session exists", wrapper.wrap ->
        @req.url = "/sessions/tokenHash"
        @req.method = "GET"
        @req._parsedUrl = pathname: @req.url
        user = username: "nameuser", tokens: [
            hash: "tokenHash", expires: new Date Date.now() + 10000
        ]

        mongoose.Model.findOne.yields null, user
        symfio.plugins.auth @container, ->
        sessionCheckerMiddleware = @app.use.secondCall.args[0]
        sessionCheckerMiddleware @req, @res, ->
        @res.send.calledOnce.should.be.true
        @res.send.firstCall.args[0].should.equal 200

    it "should respond with 404 if session doesn't exists", wrapper.wrap ->
        @req.url = "/sessions/tokenHash"
        @req.method = "GET"
        @req._parsedUrl = pathname: @req.url
        user = username: "nameuser", tokens: [
            hash: "tokenHash", expires: new Date Date.now() - 10000
        ]

        mongoose.Model.findOne.yields null, user
        symfio.plugins.auth @container, ->
        sessionCheckerMiddleware = @app.use.secondCall.args[0]
        sessionCheckerMiddleware @req, @res, ->
        @res.send.calledOnce.should.be.true
        @res.send.firstCall.args[0].should.equal 404
