sequence = require "when/sequence"
kantaina = require "kantaina"


class Symfio extends kantaina.Container
  constructor: (name, applicationDirectory) ->
    super()
    @plugins = []

    @set "name", name
    @set "applicationDirectory", applicationDirectory
    @set "env", process.env.NODE_ENV or "development"
    @set "logger",
      silly: ->
      debug: ->
      verbose: ->
      info: ->
      warn: ->
      error: ->

  use: (plugin) ->
    @plugins.push @inject plugin

  load: ->
    sequence(@plugins).then =>
      @emit "loaded"


module.exports = (name, applicationDirectory) ->
  new Symfio name, applicationDirectory

module.exports.Symfio = Symfio
