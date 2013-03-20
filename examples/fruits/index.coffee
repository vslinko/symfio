symfio = require "../.."

container = symfio "fruits-example", __dirname
loader    = container.get "loader"

loader.use symfio.plugins.express
loader.use symfio.plugins.mongoose

loader.use (container, callback) ->
  connection = container.get "connection"
  mongoose   = container.get "mongoose"

  FruitSchema = new mongoose.Schema
    name: String

  connection.model "fruits", FruitSchema

  callback()

loader.use symfio.plugins.fixtures
loader.use symfio.plugins.cruder

loader.use (container, callback) ->
  connection = container.get "connection"
  unloader   = container.get "unloader"
  cruder     = container.get "cruder"
  app        = container.get "app"
  
  Fruit = connection.model "fruits"

  app.get "/fruits", cruder.list Fruit.find().sort(name: -1)

  unloader.register (callback) ->
    connection.db.dropDatabase ->
      callback()

  callback()

loader.load() if require.main is module
module.exports = container
