sequence = require "when/sequence"
kantaina = require "kantaina"


class Symfio extends kantaina.Container
  constructor: ->
    super()
    @plugins = []

  use: (plugin) ->
    @plugins.push @inject plugin

  load: ->
    sequence(@plugins).then =>
      @emit "loaded"


module.exports = (name, applicationDirectory) ->
  symfio = new Symfio

  symfio.set "name", name
  symfio.set "applicationDirectory", applicationDirectory

  symfio


module.exports.Symfio = Symfio
