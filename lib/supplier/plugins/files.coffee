# Upload files.
# Upload only first file. Return file path in Location header.
#
#     supplier = require "supplier"
#     container = supplier "example", __dirname
#     loader = container.get "loader"
#     loader.use supplier.plugins.assets
#     loader.use supplier.plugins.express
#     loader.use supplier.plugins.files
fileupload = require "fileupload"
path = require "path"


#### Required plugins:
#
# * [__Express__](express.html).
# * [__Assets__](assets.html).
#
#### Required configuration:
#
# * __upload directory__ — Directory for uploading files.
module.exports = (container, callback) ->
    loader = container.get "loader"
    logger = container.get "logger"

    container.set "upload directory",
        path.join container.get("public directory"), "upload"

    loader.once "configured", ->
        logger.info "configured", "files"

        app = container.get "app"
        publicDirectory = container.get "public directory"
        uploadDirectory = container.get "upload directory"

        unless uploadDirectory.indexOf publicDirectory > -1
            logger.warn "Upload path not public"
                
        upload = fileupload.createFileUpload uploadDirectory
        wrapMiddleware = (req, res, callback) ->
            files = Object.keys(req.files)
            if files.length > 1
                req.files = [
                    req.files[files.shift()]    
                ]
                
            upload.middleware req, res, callback

        app.post '/upload', wrapMiddleware, (req, res) ->
            unless uploadDirectory.indexOf publicDirectory > -1
                return res.send 404

            for field of req.body
                break

            metadata = req.body[field].shift()

            res.set "Location",
                path.join uploadDirectory.replace(publicDirectory, ""),
                    metadata.path, metadata.basename
            res.send 201

    callback.injected()
    callback.configured()
