# Authentication using tokens.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.mongoose
#     loader.use supplier.plugins.auth
crypto = require "crypto"


#### Required plugins:
#
# * [__Express__](express.html).
# * [__Mongoose__](mongoose.html).
#
#### Can be configured:
#
# * __token expires__ — Token expiration.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "injecting", "auth"
    container.set "token expires", "1 week"

    loader.once "configured", ->
        logger.info "loading", "auth"

        app = container.get "app"
        expires = container.get "token expires"
        mongoose = container.get "mongoose"
        connection = container.get "connection"

        hash = (data) ->
            h = crypto.createHash "sha256"
            h.update data, "utf8"
            h.digest "hex"

        randomHash = ->
            hash String Math.random()

        password = (password, salt) ->
            hash "#{password}:#{salt}"

        TokenSchema = new mongoose.Schema
            token: type: String, index: unique: true
            createdAt: type: Date, default: Date.now, index: expires: expires

        UserSchema = new mongoose.Schema
            username: type: String, required: true
            password: type: String, required: true
            salt: type: String, required: true
            tokens: [TokenSchema]
            metadata: type: mongoose.Schema.Types.Mixed

        UserSchema.pre "validate", (callback) ->
            @salt = randomHash() unless @salt
            callback()

        UserSchema.pre "save", (callback) ->
            @password = password @password, @salt
            callback()

        User = connection.model "users", UserSchema

        app.use (req, res, callback) ->
            authHeader = req.get "Authorization"

            return callback() unless authHeader
            return callback() unless authHeader.indexOf "Token " is 0

            authToken = authHeader.replace "Token ", ""

            User.findOne "tokens.token": authToken, (err, user) ->
                return callback() if err or not user

                req.user = username: user.username
                callback()

        app.post "/sessions", (req, res) ->
            User.findOne username: req.body.username, (err, user) ->
                return res.send 500 if err
                return res.send 401 unless user

                if password(req.body.password, user.salt) != user.password
                    return res.send 401

                authToken = randomHash()

                user.tokens.push
                    token: authToken

                user.save ->
                    res.send authToken: authToken

        callback.loaded()

    callback.injected()
    callback.configured()
