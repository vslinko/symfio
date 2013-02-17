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
    supply.log "configuring", "fixtures"

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
                                callback err

                        (fixture, callback) ->
                            collection = db.collection task.collection
                            collection.count (err, count) ->
                                return callback err if err
                                return callback null if count > 0

                                supply.log "loading fixture", task.collection
                                collection.insert fixture, safe: true, callback
                    ], callback

                async.forEach tasks, worker, ->
                    callback()

        if connection.readyState is 1
            loadFixtures()
        else
            connection.on "connected", loadFixtures

    callback.configured()
