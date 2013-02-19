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
    supply.info "configuring", "fixtures"

    supply.on "configured", ->
        fixturesDirectory = supply.get "fixtures directory"
        connection = supply.get "connection"
        db = connection.db

        loadFixtures = ->
            fs.readdir fixturesDirectory, (err, files) ->
                return callback.loaded() unless files

                # The fixture must be a JSON file named like a mongodb
                # collection.
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

                            #   1. Create model for fixture
                            #     UserSchema = new mongoose.Schema
                            #       username: type: "string", required: true
                            #     
                            #     User = supply.get("connection").model "users"
                            #       , UserSchema
                            #
                            #   2. Create fixtures file with array of user data
                            #     [{
                            #       username: 'ExampleOfFixture'
                            #     }]
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
                    callback()

        if connection.readyState is 1
            loadFixtures()
        else
            connection.on "connected", loadFixtures

    callback.configured()
