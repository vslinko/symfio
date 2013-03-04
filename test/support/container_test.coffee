symfio = require "../.."
sinon = require "sinon"


containerConfigurator = ->
    @container = symfio.container()

    @container.set "name", "symfio"
    @container.set "silent", true

    @stub symfio.logger.Logger.prototype
    @logger = new symfio.logger.Logger
    @container.set "logger", @logger

    @stub symfio.loader.Loader.prototype
    @loader = new symfio.loader.Loader
    @container.set "loader", @loader

    @stub symfio.unloader.Unloader.prototype
    @unloader = new symfio.unloader.Unloader
    @container.set "unloader", @unloader


class ContainerTest
    constructor: (@configurator) ->

    loader: ->
        =>
            @sandbox = sinon.sandbox.create()
            containerConfigurator.call @sandbox
            @configurator.call @sandbox

    unloader: ->
        =>
            @sandbox.restore()

    wrap: (test) ->
        (callback) =>
            return test.call @sandbox, callback if test.length > 0
            test.call @sandbox
            callback()


module.exports = (configurator) ->
    new ContainerTest configurator

