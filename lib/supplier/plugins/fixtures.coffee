# Load fixtures to mongodb collection from fixtures directory.
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.mongoose
#     supply.use supplier.plugins.fixtures
#     supply.set "connection string", "mongodb://localhost/test"
#     supply.set "fixtures directory", "#{__dirname}/fixtures"
async = require "async"
path = require "path"
fs = require "fs"


#### Required plugins:
#
# * [__Mongoose__](mongoose.html).
#
#### Required configuration:
#
# * __fixtures directory__ — Directory with fixtures.
module.exports = (supply, callback) ->
    supply.on "configured", ->
        supply.info "loading", "fixtures"

        fixturesDirectory = supply.get "fixtures directory"
        connection = supply.get "connection"
        db = connection.db

        loadFixtures = ->
            fs.readdir fixturesDirectory, (err, files) ->
                return callback.loaded() unless files

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
                            #     connection = supply.get "connection"
                            #     User = connection.model "users", UserSchema
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
                                supply.warn err
                                return callback null
                            
                            model.count (err, count) ->
                                return callback err if err
                                return callback null if count > 0

                                supply.info "loading fixture", task.collection

                                itemWorker = (data, callback) ->
                                    item = new model data
                                    item.save callback

                                async.forEach fixture, itemWorker, callback
                    ], callback

                async.forEach tasks, worker, ->
                    callback.loaded()

        if connection.readyState is 1
            loadFixtures()
        else
            connection.on "connected", loadFixtures

    callback.injected()
    callback.configured()
