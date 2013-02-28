supplier = require "../.."


module.exports = (sandbox) ->
    container = supplier.container()

    container.set "name", "supplier"
    container.set "silent", true

    sandbox.stub supplier.logger.Logger.prototype
    container.set "logger", new supplier.logger.Logger

    sandbox.stub supplier.loader.Loader.prototype
    container.set "loader", new supplier.loader.Loader

    sandbox.stub supplier.unloader.Unloader.prototype
    container.set "unloader", new supplier.unloader.Unloader

    container
