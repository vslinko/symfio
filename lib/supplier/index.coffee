plugins = require "./plugins"
events = require "events"
async = require "async"


class Supplier extends events.EventEmitter
    constructor: (pluginsConcurrency = 10) ->
        super

        @configuration = {}

        @configured = 0
        @loaded = 0
        @length = 0

        pluginWorker = (plugin, callback) =>
            pluginCallback = ->
                pluginCallback.configured()
                pluginCallback.loaded()

            pluginCallback.configured = =>
                @configured += 1
                @emit "configured" if @configured == @length

            pluginCallback.loaded = =>
                @loaded += 1
                @emit "loaded" if @loaded == @length

            plugin @, pluginCallback

        @plugins = async.queue pluginWorker, pluginsConcurrency

    set: (name, value) ->
        @configuration[name] = value
        @emit "changed #{name}", value

    get: (name) ->
        @configuration[name]

    wait: (name, listener) ->
        if @configuration[name]
            listener @configuration[name]
        else
            @once "changed #{name}", listener

    use: (plugin) ->
        @plugins.push plugin
        @length += 1


createSupplier = (directory, name) ->
    new Supplier directory, name


module.exports = createSupplier
module.exports.Supplier = Supplier
module.exports.plugins = plugins
