# Handle file uploading.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.assets
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.uploads
fileupload = require "fileupload"
errors = require "../errors"
path = require "path"


#### Required plugins:
#
# * [__Express__](express.html).
# * [__Assets__](assets.html).
#
#### Can be configured:
#
# * __uploads directory__ — Directory for uploading files.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    loader.once "configured", ->
        logger.info "loading", "uploads"

        uploadsDirectory = container.get "uploads directory"
        publicDirectory = container.get "public directory"
        app = container.get "app"

        unless uploadsDirectory.indexOf(publicDirectory) == 0
            return logger.error errors.UPLOAD_DIRECTORY_IS_NOT_PUBLIC

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

            # Location header contains link to uploaded file.
            res.set "Location", path.join prefix, file.path, file.basename
            res.send 201

    callback.injected()
    callback.configured()