supplier = require "../.."
sinon = require "sinon"


containerConfigurator = ->
    @container = supplier.container()

    @container.set "name", "supplier"
    @container.set "silent", true

    @stub supplier.logger.Logger.prototype
    @logger = new supplier.logger.Logger
    @container.set "logger", @logger

    @stub supplier.loader.Loader.prototype
    @loader = new supplier.loader.Loader
    @container.set "loader", @loader

    @stub supplier.unloader.Unloader.prototype
    @unloader = new supplier.unloader.Unloader
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

