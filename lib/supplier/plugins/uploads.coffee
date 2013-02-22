# Handle file uploading.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.assets
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.uploads
fileupload = require "fileupload"
path = require "path"


#### Required plugins:
#
# * [__Express__](express.html).
# * [__Assets__](assets.html).
#
#### Required configuration:
#
# * __uploads directory__ — Directory for uploading files.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"


    loader.once "configured", ->
        logger.info "loading", "uploads"

        app = container.get "app"
        publicDirectory = container.get "public directory"
        uploadsDirectory = container.get "uploads directory"
        
        unless uploadsDirectory.indexOf(publicDirectory) is 0
            return logger.error 1, "Uploads directory isn't in public directory"

        # Handles only one file.
        upload = fileupload.createFileUpload uploadsDirectory
        middleware = (req, res, callback) ->
            return res.send 400 unless Object.keys(req.body).length is 0
            return res.send 400 unless Object.keys(req.files).length is 1
            upload.middleware req, res, callback

        prefix = uploadsDirectory.replace publicDirectory, ""
        app.post "/uploads", middleware, (req, res) ->
            key = Object.keys(req.body).shift()
            file = req.body[key].shift()

            # Response with path to uploaded file in the Location header.
            res.set "Location", path.join prefix, file.path, file.basename
            res.send 201

    callback.injected()
    callback.configured()
