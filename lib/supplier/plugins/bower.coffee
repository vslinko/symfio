# Install components from the Bower repository in the public directory.
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.bower
#     supply.set "components", ["jquery", "bootstrap"]
#     supply.set "public directory", "#{__dirname}/public"
bower = require "bower"
path = require "path"
fs = require "fs"


# Installs components one time in hour.
HOUR = 60 * 60 * 1000


#### Required configuration:
#
# * __components__ — Array with components.
# * __public directory__ — Directory with assets.
module.exports = (supply, callback) ->
    supply.info "configuring", "bower"

    supply.on "configured", ->
        supply.info "loading", "bower"

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
