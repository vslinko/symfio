# Just provide CRUD module.
#
#     supplier = require "supplier"
#     container = supplier()
#     loader = container.get "loader"
#     loader.use supplier.plugins.crud
crud = require "rithis-crud"


#### Provides:
#
# * __crud__ — CRUD module.
module.exports = (container, callback) ->
    logger = container.get "logger"

    logger.info "injecting", "crud"
    container.set "crud", crud

    callback()
