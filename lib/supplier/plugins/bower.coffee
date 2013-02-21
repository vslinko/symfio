# Install components from the Bower repository to the public directory.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     container.set "components", ["jquery", "bootstrap"]
#     loader = container.get "loader"
#     loader.use supplier.plugins.bower
bower = require "bower"
path = require "path"
fs = require "fs"


# Installs components one time in hour.
HOUR = 60 * 60 * 1000


#### Required configuration:
#
# * __components__ — Array with components.
# * __public directory__ — Directory with assets.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    loader.once "configured", ->
        logger.info "loading", "bower"

        components = container.get "components"
        publicDirectory = container.get "public directory"
        componentsDirectory = path.join publicDirectory, "components"

        fs.stat componentsDirectory, (err, stats) ->
            if not err and Date.now() - stats.ctime < HOUR
                return callback.loaded()

            cwd = process.cwd()
            process.chdir publicDirectory

            installation = bower.commands.install components

            unless container.get "silent"
                installation.on "data", (data) ->
                    console.log data

            installation.on "end", ->
                process.chdir cwd
                callback.loaded()

    callback.injected()
    callback.configured()
