require "colors"


class Logger
    constructor: (@name, @silent = false) ->

    # To standardize output logger has methods `info`, `warn` and `error`.
    # Method `info` has following arguments:
    #
    # * __action__ — Name of the action performed.
    # * __shizzle__ — More information about action (arguments).
    # * ___name___ — Application name, default value taken from the container.
    info: (action, shizzle, name = @name) ->
        @_message action, shizzle, name, "cyan"

    # Methods `warn` has only __shizzle__ and __name__ arguments:
    #
    # * __shizzle__ — More information about action (arguments).
    # * ___name___ — Application name, default value taken from the container.
    warn: (shizzle, name = @name) ->
        @_message "warn", shizzle, name, "yellow"

    # Method `error` has following arguments:
    #
    # * __error__ — Error object from [errors.coffee](errors.html).
    # * ___name___ — Application name, default value taken from the container.
    #
    # Aslo `error` method terminates the application.
    error: (error, name = @name) ->
        @_message "error", error.message, name, "red"
        process.exit error.code

    _message: (action, shizzle, name, color) ->
        return if @silent

        message = [name]
        if action
            message.push String(action)[color]
            message.push String(shizzle).grey if shizzle

        console.log message.join " "


createInstance = (container) ->
    name = container.get "name"
    silent = container.get "silent"
    logger = new Logger name, silent

    container.on "changed silent", (value) ->
        logger.silent = value

    logger


module.exports = createInstance
module.exports.Logger = Logger
