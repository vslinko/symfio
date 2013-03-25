container = require "../container"
unloader  = require "../unloader"
logger    = require "../logger"
loader    = require "../loader"
sinon     = require "sinon"


containerConfigurator = ->
  @container = container()

  @container.set "name", "symfio"
  @container.set "silent", true

  @stub logger.Logger.prototype
  @logger = new logger.Logger
  @container.set "logger", @logger

  @stub loader.Loader.prototype
  @loader = new loader.Loader
  @container.set "loader", @loader

  @stub unloader.Unloader.prototype
  @unloader = new unloader.Unloader
  @container.set "unloader", @unloader


class ContainerTest
  constructor: (@configurator) ->

  beforeEach: ->
    =>
      @sandbox = sinon.sandbox.create()
      containerConfigurator.call @sandbox
      @configurator.call @sandbox

  afterEach: ->
    => @sandbox.restore()

  wrap: (test) ->
    (callback) =>
      if test.length > 0
        test.call @sandbox, callback
      else
        test.call @sandbox
        callback()


module.exports = (configurator) ->
  new ContainerTest configurator
