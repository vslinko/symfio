
supplier = require "supplier"
semver = require "semver"
errors = require "./errors"
async = require "async"
path = require "path"
npm = require "npm"
pkg = require "../../package.json"
fs = require "fs.extra"
require "shelljs/global"

logger = new supplier.logger.Logger "supplier"

version = pkg.version
version = "~#{version.split(".").slice(0,2).join "."}" if semver.valid version

project = process.argv[2]

target = path.join process.cwd(), project

gitignore = """
    node_modules
"""

readme = """
    #{project} readme
"""

style = """
    body
      width 500px
      margin 75px auto
      font 14px "Lucida Grande", Helvetica, Arial, sans-serif
"""

index = """
    html
        head
            title= title
            link(rel="stylesheet", href="/styles/style.css")
        body
            h1= title
            p Welcome to #{project}
"""

app = """
    supplier = require "supplier"

    container = supplier "#{project}", __dirname
    loader = container.get "loader"
    
    loader.use supplier.plugins.express
    loader.use supplier.plugins.assets
    
    loader.load()
"""

write = (filename, data) ->
    logger.info "creating file", filename
    fs.writeFileSync filename, data

mkdir = (path) ->
    logger.info "creating directory", path
    fs.mkdirpSync path

createApplicationAt = (target, callback) ->
    async.series [
        (callback) ->
            mkdir target
            mkdir path.join target, "public"
            mkdir path.join target, "public", "images"
            mkdir path.join target, "public", "scripts"
            mkdir path.join target, "public", "styles"
            mkdir path.join target, "views"

            start = "node_modules/.bin/coffee " +
                "#{project}.coffee"

            pkgData =
                name: project
                version: '0.0.0'
                scripts:
                    start: start
                dependencies:
                    "coffee-script": pkg.dependencies["coffee-script"]
                    "supplier": version

            write path.join(target, "README.md"), readme
            write path.join(target, ".gitignore"), gitignore
            write path.join(target, 'package.json'), JSON.stringify pkgData, null, 4
            write path.join(target, "#{project}.coffee"), app
            write path.join(target, "public", "styles", "style.styl"), style
            write path.join(target, "views", "index.jade"), index
            callback()

        (callback) ->
            npm.load {prefix: target}, (err) ->
                if err
                    logger.error errors.COMMAND_NPM_LOAD_ERROR
                    return callback()

                npm.commands.install [], (err, data) ->
                    callback()

        (callback) ->
            logger.info "checking git installation"
            logger.error errors.COMMAND_GIT_NOT_INSTALLED unless which "git"
            callback()

        (callback) ->
            logger.info "initializing git repositoty"
            exec "git init", {cwd: target}, (err, stdout, stderr) ->
                logger.error errors.COMMAND_GIT_INIT_REPOSITORY_ERROR if err
                callback()

        (callback) ->
            logger.info "committing"
            exec "git add . && git commit -m 'Initial commit'",
                {cwd: target}, (err, stdout, stderr) ->
                    logger.error errors.COMMAND_GIT_COMMIT_ERROR if err
                    callback()
        ], callback

exports.run = (callback) ->
    logger.error errors.COMMAND_PROJECT_NAME_NOT_CORRECT unless project
    logger.error errors.COMMAND_DESTINATION_EXISTS if fs.existsSync target

    createApplicationAt target, callback
