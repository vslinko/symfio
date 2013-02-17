async = require "async"
path = require "path"
fs = require "fs"


module.exports = (supply, callback) ->
    supply.log "configuring", "fixtures"

    supply.on "configured", ->
        fixturesDirectory = supply.get "fixtures directory"
        connection = supply.get "connection"
        db = connection.db

        loadFixtures = ->
            fs.readdir fixturesDirectory, (err, files) ->
                return callback.loaded() unless files

                # prepare tasks
                tasks = []
                for file in files
                    if path.extname(file) is ".json"
                        tasks.push
                            collection: path.basename file, ".json"
                            file: path.join fixturesDirectory, file

                # worker for fixture task
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

                # run workers for each fixtures
                async.forEach tasks, worker, ->
                    callback()

        # one means connected
        if connection.readyState is 1
            loadFixtures()
        else
            connection.on "connected", loadFixtures

    callback.configured()
