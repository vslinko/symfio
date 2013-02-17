bower = require "bower"
path = require "path"
fs = require "fs"


HOUR = 60 * 60 * 1000


module.exports = (supply, callback) ->
    supply.log "configuring", "bower"

    supply.on "configured", ->
        supply.log "loading", "bower"

        components = supply.get "components"
        publicDirectory = supply.get "public directory"
        componentsDirectory = path.join publicDirectory, "components"

        fs.stat componentsDirectory, (err, stats) ->
            if not err and Date.now() - stats.ctime < HOUR
                return callback.loaded()

            cwd = process.cwd()
            process.chdir publicDirectory

            installation = bower.commands.install components

            unless supply.get "silent"
                installation.on "data", (data) ->
                    console.log data

            installation.on "end", ->
                process.chdir cwd
                callback.loaded()

    callback.configured()
