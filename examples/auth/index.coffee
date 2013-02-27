supplier = require "../.."


container = supplier "auth-example", __dirname
loader = container.get "loader"

loader.use supplier.plugins.express
loader.use supplier.plugins.mongoose
loader.use supplier.plugins.fixtures
loader.use supplier.plugins.auth

loader.use (container, callback) ->
    connection = container.get "connection"
    unloader = container.get "unloader"
    app = container.get "app"

    app.get "/", (req, res) ->
        return res.send 401 unless req.user
        res.send user: req.user

    unloader.register (callback) ->
        connection.db.dropDatabase ->
            callback()

    callback()


module.exports = container

if require.main is module
    loader.load()
