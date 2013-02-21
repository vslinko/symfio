# User token authentication 
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.mongoose
#     loader.use supplier.plugins.auth
expires = require "expires"
crypto = require "crypto"
json = require "json-output"


#### Can be configured:
#
# * __expire__ — Token expiration.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    container.set "expire", "1 week"

    loader.once "configured", ->
        logger.info "configured", "auth"

        app = container.get "app"
        expire = container.get "expire"
        connection = container.get "connection"
        mongoose = container.get "mongoose"

        generateSalt = ->
            generateHash String((Math.random() + 2) * Math.random())
    
        hashPassword = (password, salt) ->
            generateHash password + salt
        
        generateHash = (data) ->
            crypto.createHash("sha256")
                .update(data, "utf8")
                .digest "hex"
    
        TokenSchema = new mongoose.Schema
            token: type: "string"
            expire: type: Date
    
        UserSchema = new mongoose.Schema
            username: type: "string", required: true
            password: type: "string", required: true
            salt: type: "string", required: true
            tokens: [TokenSchema]
            metadata: type: mongoose.Schema.Types.Mixed
    
        UserSchema.pre "validate", (callback) ->
            @salt = generateSalt() unless @salt
            callback()
    
        UserSchema.pre "save", (callback) ->
            @password = hashPassword @password, @salt
            callback()
    
        User = connection.model "users", UserSchema
    
         # Populate user
        app.use (req, res, callback) ->
            authHeader = req.get "Authorization"
            return callback() unless authHeader
            return callback() unless authHeader.indexOf "Token" > -1
                    
            authToken = authHeader.replace "Token ", ""

            query = tokens: $elemMatch: token: authToken
            User.findOne query, (err, user) ->
                return callback() if err or !user
                return callback() if expires.expired user.tokenExpire
    
                req.user =
                    username = user.username
    
                callback()
    
        # Authenticate
        app.post "/auth-token", (req, res) ->
            errorCallback = (err, status) ->
                res.json json.error(err), status or 500
       
            User.findOne username: req.body.username, (err, user) ->
                return errorCallback err if err
    
                unless user
                    return errorCallback "User does not exists", 404
    
                if hashPassword(req.body.password, user.salt) != user.password
                    return errorCallback "Invalid password", 401
    
                authToken = generateHash(
                    "#{user.username}+#{user.password}+#{generateSalt()}"
                )
    
                user.tokens.push
                    token: authToken
                    expire: new Date expires.after expire
    
                user.save ->
                    res.json authToken: authToken
        
        callback.loaded()
        
    callback.injected()
    callback.configured()
