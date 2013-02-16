coffeescript = require "connect-coffee-script"
responsive = require "stylus-responsive"
express = require "express"
stylus = require "stylus"
jade = require "jade-static"
path = require "path"
nib = require "nib"


compilerFactory = (str, path) ->
    compiler = stylus str
    
    compiler.set "filename", path
    compiler.set "compress", false
    
    compiler.use nib()
    compiler.use responsive
    
    compiler.import "nib"
    compiler.import "responsive"


module.exports = (supply, callback) ->
    supply.on "configured", ->
        app = supply.get "app"
        publicDirectory = supply.get "public directory"

        app.configure ->
            app.use stylus.middleware
                src: publicDirectory
                compile: compilerFactory

            app.use jade publicDirectory
            app.use coffeescript publicDirectory
            app.use express.static publicDirectory

        callback.loaded()

    callback.configured()
