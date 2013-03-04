symfio = require "../.."


container = symfio "fruits-example", __dirname
loader = container.get "loader"

loader.use symfio.plugins.express
loader.use symfio.plugins.mongoose

loader.use (container, callback) ->
    connection = container.get "connection"
    mongoose = container.get "mongoose"

    FruitSchema = new mongoose.Schema
        name: String

    connection.model "fruits", FruitSchema

    callback()

loader.use symfio.plugins.fixtures
loader.use symfio.plugins.crud

loader.use (container, callback) ->
    connection = container.get "connection"
    unloader = container.get "unloader"
    crud = container.get "crud"
    app = container.get "app"

    Fruit = connection.model "fruits"

    app.get "/fruits", crud.list(Fruit).sort(name: -1).make()

    unloader.register (callback) ->
        connection.db.dropDatabase ->
            callback()

    callback()


module.exports = container

if require.main is module
    loader.load()
