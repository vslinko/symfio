# Just provide CRUD module.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.crud
#     loader.load()
crud = require "rithis-crud"


#### Provides:
#
# * __crud__ — CRUD module.
module.exports = (container, callback) ->
    logger = container.get "logger"

    logger.info "loading plugin", "crud"
    container.set "crud", crud

    callback()
