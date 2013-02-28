fakeContainer = require "./support/fake_container"
mongoose = require "mongoose"
supplier = require ".."
express = require "express"
sinon = require "sinon"
require "should"


describe "auth", ->
    container = null
    sandbox = null
    app = null
    req = null

    beforeEach ->
        sandbox = sinon.sandbox.create()
        container = fakeContainer sandbox

        sandbox.stub mongoose.Model, "findOne"
        sandbox.stub mongoose.Connection.prototype, "model"
        mongoose.Connection.prototype.model.returns mongoose.Model
        container.set "connection", new mongoose.Connection
        container.set "mongoose", mongoose

        app = express()
        sandbox.spy app, "use"
        container.set "app", app

        req = get: sandbox.stub().returns "Token shmoken"

    afterEach ->
        sandbox.restore()

    it "should populate user in request object", ->
        user = username: "nameuser", tokens: [
            hash: "shmoken", expires: new Date Date.now() + 10000
        ]
        mongoose.Model.findOne.yields null, user

        supplier.plugins.auth container, ->
            populateMiddleware = app.use.firstCall.args[0]
            populateMiddleware req, null, ->
                req.should.have.property "user"
                req.user.username.should.equal user.username
                req.user.token.hash.should.equal "shmoken"

    it "should not populate user in request object if token is expired", ->
        user = username: "nameuser", tokens: [
            hash: "shmoken", expires: new Date Date.now() - 10000
        ]
        mongoose.Model.findOne.yields null, user

        supplier.plugins.auth container, ->
            populateMiddleware = app.use.firstCall.args[0]
            populateMiddleware req, null, ->
                req.should.not.have.property "user"

    it "should return 500 http code when mongo failed", (callback) ->
        mongoose.Model.findOne.yields new Error

        req.url = "/sessions"
        req.method = "POST"
        req.body = username: "username"
        res = send: sinon.mock().once().withExactArgs 500

        supplier.plugins.auth container, ->
            authenticateMiddleware = app.use.lastCall.args[0]
            authenticateMiddleware req, res

            res.send.verify()
            callback()
