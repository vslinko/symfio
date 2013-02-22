# Compile and serve assets from public directory.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.assets
coffeescript = require "connect-coffee-script"
responsive = require "stylus-responsive"
express = require "express"
stylus = require "stylus"
jade = require "jade-static"
path = require "path"
nib = require "nib"


# Used custom compiler for Stylus with imported `nib` and `responsive`.
compilerFactory = (str, path) ->
    compiler = stylus str
    
    compiler.set "filename", path
    compiler.set "compress", false
    
    compiler.use nib()
    compiler.use responsive
    
    compiler.import "nib"
    compiler.import "responsive"


#### Can be configured:
#
# * __public directory__ — Directory with assets.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    loader.once "injected", ->
        logger.info "configuring", "assets"

        publicDirectory = container.get "public directory"
        app = container.get "app"

        app.configure ->
            app.use stylus.middleware
                src: publicDirectory
                compile: compilerFactory

            app.use jade publicDirectory
            app.use coffeescript publicDirectory
            app.use express.static publicDirectory

        callback.configured()
        callback.loaded()

    callback.injected()
