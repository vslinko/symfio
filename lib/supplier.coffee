#### Welcome to Supplier documentation
# 
# Supplier is a thin layer between Node.JS modules. Supplier allows you to
# connect Node.JS modules using a plugin system. Plugins are loaded
# asynchronously, which can reduce the time of application initialization.
container = require "./supplier/container"
plugins = require "./supplier/plugins"
loader = require "./supplier/loader"
logger = require "./supplier/logger"


createInstance = (name = "supplier") ->
    instance = container()
    instance.set "name", name
    instance.set "silent", process.env.NODE_ENV is "test"
    instance.set "logger", logger instance
    instance.set "loader", loader instance
    instance


module.exports = createInstance
module.exports.container = container
module.exports.loader = loader
module.exports.logger = logger
module.exports.plugins = plugins
