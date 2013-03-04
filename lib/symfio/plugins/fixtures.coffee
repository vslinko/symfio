# Load fixtures to mongodb collection from fixtures directory.
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use symfio.plugins.fixtures
#     loader.use symfio.plugins.mongoose
#     loader.load()
async = require "async"
path = require "path"
fs = require "fs"


#### Required plugins:
#
# * [__Mongoose__](mongoose.html).
#
#### Can be configured:
#
# * __fixtures directory__ — Directory with fixtures.
module.exports = (container, callback) ->
    fixturesDirectory = container.get "fixtures directory"
    connection = container.get "connection"
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "loading plugin", "fixtures"

    fs.readdir fixturesDirectory, (err, files) ->
        return callback() unless files

        tasks = []
        for file in files
            if path.extname(file) is ".json"
                tasks.push
                    collection: path.basename file, ".json"
                    file: path.join fixturesDirectory, file

        worker = (task, callback) ->
            async.waterfall [
                (callback) ->
                    fs.readFile task.file, callback

                (data, callback) ->
                    try
                        callback null, JSON.parse data
                    catch err
                        callback null, false

                (fixture, callback) ->
                    return callback() unless fixture

                    # For make fixtures work you need define the model:
                    #
                    #     UserSchema = new mongoose.Schema
                    #         username: type: "string", required: true
                    #
                    #     connection = container.get "connection"
                    #     connection.model "users", UserSchema
                    #
                    # And create fixtures file with array named like
                    # collection name:
                    #
                    #     [
                    #         {"username": "ExampleOfFixture"}
                    #     ]
                    try
                        model = connection.model task.collection
                    catch err
                        logger.warn err
                        return callback null

                    model.count (err, count) ->
                        return callback err if err
                        return callback null if count > 0

                        logger.info "loading fixture", task.collection

                        itemWorker = (data, callback) ->
                            item = new model data
                            item.save callback

                        async.forEach fixture, itemWorker, ->
                            callback()
            ], callback

        async.forEach tasks, worker, ->
            callback()
