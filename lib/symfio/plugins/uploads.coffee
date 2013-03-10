# Handle file uploading.
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use symfio.plugins.assets
#     loader.use symfio.plugins.express
#     loader.use symfio.plugins.uploads
#     loader.load()
fileupload = require "fileupload"
errors     = require "../errors"
path       = require "path"


#### Required plugins:
#
# * [__Express__](express.html).
# * [__Assets__](assets.html).
#
#### Can be configured:
#
# * __uploads directory__ — Directory for uploading files.
module.exports = (container, callback) ->
  uploadsDirectory = container.get "uploads directory"
  publicDirectory  = container.get "public directory"
  logger           = container.get "logger"
  app              = container.get "app"

  logger.info "loading plugin", "uploads"

  unless uploadsDirectory.indexOf(publicDirectory) == 0
    return logger.error errors.UPLOAD_DIRECTORY_IS_NOT_PUBLIC

  # Handles only one file.
  upload = fileupload.createFileUpload uploadsDirectory
  prefix = uploadsDirectory.replace publicDirectory, ""

  app.use (req, res, callback) ->
    unless req.url is "/uploads" and req.method is "POST"
      return callback()

    return res.send 400 unless Object.keys(req.body).length is 0
    return res.send 400 unless Object.keys(req.files).length is 1

    upload.middleware req, res, ->
      key = Object.keys(req.body).shift()
      file = req.body[key].shift()

      # Location header contains link to uploaded file.
      res.set "Location", "#{prefix}/#{file.path}#{file.basename}"
      res.send 201

  callback()
