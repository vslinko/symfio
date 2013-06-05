clc = require "cli-color"

class Logger
  constructor: (@name, @silent = false) ->

  info: (action, message, name = @name) ->
    @_message action, message, name, "cyan"

  warn: (message, name = @name) ->
    @_message "warn", message, name, "yellow"

  error: (message, code = 1, name = @name) ->
    @_message "error", message, name, "red"
    process.exit code

  _message: (action, message, name, color) ->
    return if @silent

    output = [name]
    if action
      output.push clc[color] action
      output.push clc.blackBright message if message

    console.log output.join " "

module.exports = (name, silent) ->
  new Logger name, silent

module.exports.Logger = Logger
