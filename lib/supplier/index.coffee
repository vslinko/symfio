plugins = require "./plugins"
events = require "events"
async = require "async"


class Supplier extends events.EventEmitter
    constructor: (directory, name, pluginsConcurrency = 10) ->
        super

        @configuration =
            directory: directory
            name: name

        @configured = 0
        @loaded = 0
        @length = 0

        pluginWorker = (plugin, callback) ->
            configured = ->
                @configured += 1
                @emit "configured" if @configured == @length

            loaded = ->
                @loaded += 1
                @emit "loaded" if @loaded == @length

            pluginCallback = ->
                pluginCallback.configured()
                pluginCallback.loaded()

            pluginCallback.configured = configured.bind @
            pluginCallback.loaded = loaded.bind @

            plugin @, pluginCallback

        @plugins = async.queue pluginWorker.bind(@), pluginsConcurrency

    set: (name, value) ->
        @configuration[name] = value

    get: (name) ->
        @configuration[name]

    use: (plugin) ->
        @plugins.push plugin
        @length += 1


createSupplier = (directory, name) ->
    new Supplier directory, name


module.exports = createSupplier
module.exports.Supplier = Supplier
module.exports.plugins = plugins
