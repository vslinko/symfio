events = require "events"
async = require "async"


class Loader extends events.EventEmitter
    constructor: (@container) ->
        @plugins = []

    # To connect plugin pass it to `use` method of loader instance.
    use: (plugin) ->
        @plugins.push plugin

    load: (callback) ->
        @once "loaded", callback if typeof callback is "function"

        pluginWorker = (plugin, callback) =>
            # The plugin is a function that takes two arguments:
            #
            # * __container__ — Container instance.
            # * __callback__ — Callback to notify the loader.
            plugin @container, callback

        async.forEachSeries @plugins, pluginWorker, =>
            @emit "loaded"


createInstance = (container) ->
    new Loader container


module.exports = createInstance
module.exports.Loader = Loader
