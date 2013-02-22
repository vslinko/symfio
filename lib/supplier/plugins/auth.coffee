# Authentication using tokens.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.auth
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.mongoose
crypto = require "crypto"
ms = require "ms"


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
    container.set "token expires", "7d"

    loader.once "configured", ->
        logger.info "loading", "auth"

        connection = container.get "connection"
        mongoose = container.get "mongoose"
        expires = ms container.get "token expires"
        app = container.get "app"

        hash = (data) ->
            h = crypto.createHash "sha256"
            h.update data, "utf8"
            h.digest "hex"

        randomHash = ->
            hash String Math.random()

        password = (password, salt) ->
            hash "#{password}:#{salt}"

        TokenSchema = new mongoose.Schema
            hash: type: String, required: true, index: unique: true
            expires: type: Date, required: true

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

            tokenHash = authHeader.replace "Token ", ""

            User.findOne "tokens.hash": tokenHash, (err, user) ->
                return callback() if err or not user

                currentToken = null
                for token in user.tokens
                    if token.hash is tokenHash
                        currentToken = token

                if not currentToken or new Date > currentToken.expires
                    return callback()

                req.user = username: user.username, token: currentToken
                callback()

        app.post "/sessions", (req, res) ->
            User.findOne username: req.body.username, (err, user) ->
                return res.send 500 if err
                return res.send 401 unless user

                if password(req.body.password, user.salt) != user.password
                    return res.send 401

                tokenHash = randomHash()

                user.tokens.push
                    hash: tokenHash
                    expires: new Date Date.now() + expires

                user.save (err) ->
                    return res.send 500 if err

                    res.send 201, token: tokenHash

        callback.loaded()

    callback.injected()
    callback.configured()
