# Authentication using tokens.
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use symfio.plugins.auth
#     loader.use symfio.plugins.express
#     loader.use symfio.plugins.mongoose
#     loader.load()
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
    connection = container.get "connection"
    mongoose = container.get "mongoose"
    expires = ms container.get "token expires", "7d"
    loader = container.get "loader"
    logger = container.get "logger"
    app = container.get "app"

    logger.info "loading plugin", "auth"

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
        password: type: String
        passwordHash: type: String, required: true
        salt: type: String, required: true
        tokens: [TokenSchema]
        metadata: type: mongoose.Schema.Types.Mixed

    UserSchema.pre "validate", (callback) ->
        @salt = randomHash() unless @salt

        if @password
            @passwordHash = password @password, @salt
            @password = undefined
            
        callback()

    User = connection.model "users", UserSchema

    findUser = (tokenHash, callback) ->
        User.findOne "tokens.hash": tokenHash, (err, user) ->
            return callback err if err
            return callback() unless user

            currentToken = null
            for token in user.tokens
                if token.hash is tokenHash
                    currentToken = token

            if not currentToken or new Date > currentToken.expires
                return callback()

            callback null, username: user.username, token: currentToken

    app.use (req, res, callback) ->
        authHeader = req.get "Authorization"

        return callback() unless authHeader
        return callback() unless authHeader.indexOf "Token " is 0

        tokenHash = authHeader.replace "Token ", ""

        findUser tokenHash, (err, user) ->
            req.user = user if user
            callback()

    app.use (req, res, callback) ->
        unless req.url.indexOf("/sessions/") is 0 and req.method is "GET"
            return callback()

        findUser req._parsedUrl.pathname.replace("/sessions/", ""),
            (err, user) ->
                res.send 500 if err
                res.send if user then 200 else 404

    app.use (req, res, callback) ->
        unless req.url is "/sessions" and req.method is "POST"
            return callback()

        User.findOne username: req.body.username, (err, user) ->
            return res.send 500 if err
            return res.send 401 unless user

            if password(req.body.password, user.salt) != user.passwordHash
                return res.send 401

            tokenHash = randomHash()

            user.tokens.push
                hash: tokenHash
                expires: new Date Date.now() + expires

            user.save (err) ->
                return res.send 500 if err

                res.send 201, token: tokenHash

    callback()
