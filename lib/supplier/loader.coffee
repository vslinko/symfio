events = require "events"
async = require "async"


class Loader extends events.EventEmitter
    constructor: (container, pluginsConcurrency = 10) ->
        super

        @injected = 0
        @configured = 0
        @loaded = 0
        @length = 0

        pluginWorker = (plugin, callback) =>
            pluginCallback = ->
                pluginCallback.injected()
                pluginCallback.configured()
                pluginCallback.loaded()

            # Plugins is loaded in three stages:
            #
            # * __Injecting.__ At this point, the plugin can list dependent
            #   plugins or inject some values to container. After successful
            #   injecting plugin should call `callback.injected()` to notify the
            #   loader. When all plugins has been notified loader then loader
            #   emits event `injected` and begin the next stage.
            pluginCallback.injected = =>
                @injected += 1
                @emit "injected" if @injected == @length

            # * __Configuration.__ At this point, the plugin can access to
            #   injected values by other plugins and manipulate with them. After
            #   successful configuration plugin should call
            #   `callback.configured()` to notify the loader. When all
            #   plugins has been notified loader then loader emits event
            #   `configured` and begin the next stage.
            pluginCallback.configured = =>
                @configured += 1
                @emit "configured" if @configured == @length

            # * __Loading.__ At this point, the plugin can read the
            #   configuration from the container, do some tasks and open some
            #   connections. After all tasks is done plugin should call
            #   `callback.loaded()` to notify the loader. When all plugins
            #   has been notified loader then loader emits event `loaded`.
            pluginCallback.loaded = =>
                @loaded += 1
                @emit "loaded" if @loaded == @length

            # The plugin is a function that takes two arguments:
            #
            # * __container__ — Container instance.
            # * __callback__ — Callback to notify the loader.
            plugin container, pluginCallback

        @plugins = async.queue pluginWorker, pluginsConcurrency

    # To connect plugin pass it to `use` method of loader instance.
    use: (plugin) ->
        @plugins.push plugin
        @length += 1


createInstance = (container) ->
    new Loader container, container.get "plugins concurrency"


module.exports = createInstance
module.exports.Loader = Loader
