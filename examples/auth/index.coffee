symfio = require "../.."

container = symfio "auth-example", __dirname
loader    = container.get "loader"

loader.use symfio.plugins.express
loader.use symfio.plugins.mongoose
loader.use symfio.plugins.auth
loader.use symfio.plugins.fixtures

loader.use (container, callback) ->
  connection = container.get "connection"
  unloader   = container.get "unloader"
  app        = container.get "app"

  app.get "/", (req, res) ->
    return res.send 401 unless req.user
    res.send user: req.user

  unloader.register (callback) ->
    connection.db.dropDatabase ->
      callback()

  callback()

loader.load() if require.main is module
module.exports = container
