# Install components from the Bower repository to the public directory.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     container.set "components", ["jquery", "bootstrap"]
#     loader = container.get "loader"
#     loader.use supplier.plugins.bower
#     loader.load()
crypto = require "crypto"
bower = require "bower"
async = require "async"
path = require "path"
fs = require "fs"


#### Required configuration:
#
# * __components__ — Array with components.
#
#### Can be configured:
#
# * __application directory__ — Directory with application sources.
# * __public directory__ — Directory with assets.
module.exports = (container, callback) ->
    applicationDirectory = container.get "application directory"
    publicDirectory = container.get "public directory"
    components = container.get "components"
    hashFile = path.join applicationDirectory, ".components"
    loader = container.get "loader"
    logger = container.get "logger"

    logger.info "loading plugin", "bower"

    hash = crypto.createHash "sha256"

    for component in components
        hash.update component, "utf8"
        hash.update ":", "utf8"

    hashString = hash.digest "hex"

    async.series [
        (callback) ->
            fs.readFile hashFile, (err, previousHash) ->
                return callback previousHash if hashString == previousHash
                callback()

        (callback) ->
            cwd = process.cwd()
            process.chdir publicDirectory

            installation = bower.commands.install components

            unless container.get "silent"
                installation.on "data", (data) ->
                    console.log data

            installation.on "end", ->
                process.chdir cwd
                callback()

        (callback) ->
            fs.writeFile hashFile, hashString, ->
                callback()
    ], callback
