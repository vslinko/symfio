#### Welcome to Supplier documentation
# 
# Supplier is a thin layer between Node.JS modules. Supplier allows you to
# connect Node.JS modules using a plugin system. Plugins are loaded
# asynchronously, which can reduce the time of application initialization.
plugins = require "./supplier/plugins"
colors = require "colors"
events = require "events"
async = require "async"


class Supplier extends events.EventEmitter
    constructor: (pluginsConcurrency = 10) ->
        super

        @configuration =
            name: "supplier"
            silent: process.env.NODE_ENV is "test"

        @configured = 0
        @loaded = 0
        @length = 0

        pluginWorker = (plugin, callback) =>
            pluginCallback = ->
                pluginCallback.configured()
                pluginCallback.loaded()

            # Plugins is loaded in two stages:
            #
            # * __Configuration.__ At this point, the plugin can list dependent
            #   plugins or set some values in application configuration. After
            #   successful configuration plugin should call
            #   `callback.configured()` to notify the application. When all
            #   plugins has been configured then application emits event
            #   `configured` and begin the next stage.
            pluginCallback.configured = =>
                @configured += 1
                @emit "configured" if @configured == @length

            # * __Loading.__ At this point, the plugin can read the
            #   configuration from the application, do some tasks, or open some
            #   connections. After all tasks is done plugin should call
            #   `callback.loaded()` to notify the application. When all plugins
            #   has been loaded then application emits event `configured`.
            pluginCallback.loaded = =>
                @loaded += 1
                @emit "loaded" if @loaded == @length

            # The plugin is a function that takes two arguments:
            #
            # * __supply__ — Application instance.
            # * __callback__ — Callback to notify the application.
            plugin @, pluginCallback

        @plugins = async.queue pluginWorker, pluginsConcurrency

    # Plugins can share settings and variables using application instance.
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

    # To connect plugin pass it to `use` method of application instance.
    use: (plugin) ->
        @plugins.push plugin
        @length += 1

    # To standardize output application instance has methods `info`, `warn`
    # and `error`. Method `info` has following arguments:
    #
    # * __action__ — Name of the action performed.
    # * __shizzle__ — More information about action (arguments).
    # * ___name___ — Application name, default value taken from the
    #   configuration.
    #
    # Methods `warn` and `error` has only __shizzle__ and __name__ arguments.
    # Aslo `error` method terminates the application.
    info: (action, shizzle, name = @configuration["name"]) ->
        @_message action, shizzle, name, "cyan"

    # Methods `warn` has only __shizzle__ and __name__ arguments:
    #
    # * __shizzle__ — More information about action (arguments).
    # * ___name___ — Application name, default value taken from the
    #   configuration.
    warn: (shizzle, name = @configuration["name"]) ->
        @_message "warn", shizzle, name, "yellow"

    # Method `error` has following arguments:
    #
    # * __code__ — Exit code.
    # * __shizzle__ — More information about action (arguments).
    # * ___name___ — Application name, default value taken from the
    #   configuration.
    #
    # Aslo `error` method terminates the application.
    error: (code, shizzle, name = @configuration["name"]) ->
        @_message "error", shizzle, name, "red"
        process.exit code

    _message: (action, shizzle, name, color) ->
        return if @get "silent"

        message = [name]
        if action
            message.push String(action)[color]
            message.push String(shizzle).grey if shizzle

        console.log message.join " "


# Application instance can be created in two ways:
#
#     supplier = require "supplier"
#     supply = supplier()
#
# Or:
#
#     supplier = require "supplier"
#     supply = new supplier.Supplier
createSupplier = (pluginsConcurrency) ->
    new Supplier pluginsConcurrency


module.exports = createSupplier
module.exports.Supplier = Supplier
module.exports.plugins = plugins
