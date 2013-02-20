# Compile and serve assets from public directory.
#
#     supplier = require "supplier"
#     supply = supplier()
#     supply.use supplier.plugins.assets
#     supply.set "public directory", "#{__dirname}/public"
coffeescript = require "connect-coffee-script"
responsive = require "stylus-responsive"
express = require "express"
stylus = require "stylus"
jade = require "jade-static"
path = require "path"
nib = require "nib"


# Using custom compiler for Stylus with imported `nib` and `responsive`.
compilerFactory = (str, path) ->
    compiler = stylus str
    
    compiler.set "filename", path
    compiler.set "compress", false
    
    compiler.use nib()
    compiler.use responsive
    
    compiler.import "nib"
    compiler.import "responsive"


#### Required configuration:
#
# * __public directory__ — Directory with assets.
module.exports = (supply, callback) ->
    supply.on "injected", ->
        supply.info "configuring", "assets"

        app = supply.get "app"
        publicDirectory = supply.get "public directory"

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
