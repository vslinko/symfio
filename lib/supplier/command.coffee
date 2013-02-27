###
# Module dependencies.
###

program = require "commander"
mkdirp = require "mkdirp"
async = require "async"
spawn = require("child_process").spawn
exec = require("child_process").exec
pkg = require "../../package.json"
fs = require "fs"
os = require "os"
p = require "path"

# Version
version = pkg.version

# CLI
program
    .version(version)
    .usage('[options] project-name')
    .option('-v, --verbose', 'Verbose')
    .parse(process.argv)

# Project name
project = program.args.shift()

# Path
path = p.join process.cwd(), project

# Default .gitignore template.
gitignore = """
    node_modules
"""

# Readme
readme = """
    #{project} readme
"""

# Default stylus template.
stylus = """
    body
      padding: 50px
      font: 14px "Lucida Grande", Helvetica, Arial, sans-serif
"""

# Index template.
index = """
    html
        head
            title= title
            link(rel='stylesheet', href='/styles/style.css')
        body
            h1= title
            p Welcome to #{project}
"""

# App template
app = """
    # require supplier module
    supplier = require "supplier"
        
    # create container
    container = supplier "#{project}", __dirname
    loader = container.get "loader"
        
    # configure connection string
    container.set "connection string", "mongodb://localhost/#{project}"
        
    # add dependent plugins
    loader.use supplier.plugins.express
    loader.use supplier.plugins.mongoose
    loader.use supplier.plugins.fixtures
        
    # define own plugin
    loader.use (container, callback) ->
        # get dependencies
        connection = container.get "connection"
        mongoose = container.get "mongoose"
        app = container.get "app"
        
        # define schemas
        MessageSchema = new mongoose.Schema
            message: type: "string"
    
        # define models
        Message = connection.model "messages", MessageSchema
        
        # define express routes
        app.get "/", (req, res) ->
            Message.find {}, (err, messages) ->
                res.send messages
    
        # our plugin is configured and loaded, allow to start server
        callback()
    
    # load all plugins
    loader.load()
"""

# Check if the given directory `path` is empty.
emptyDirectory = (path, callback) ->
    fs.readdir path, (err, files) ->
        throw err if err && 'ENOENT' != err.code
        callback !files || !files.length


# echo str > path.
write = (path, str) ->
    fs.writeFile path, str
    console.log "   \x1b[36mcreate\x1b[0m : " + path if program.verbose

# Mkdir -p.
mkdir = (path, callback) ->
    mkdirp path, '0755', (err) ->
        throw err if err
        console.log "   \x1b[36mcreate\x1b[0m : " + path  if program.verbose
        callback() if callback
        
# Exit with the given `str`.
abort = (str) ->
    console.error str
    process.exit 1

createApplicationAt = (path) ->
    async.waterfall [
        (callback) ->
            console.log "supplier creating directories and files"
            mkdir path, ->
                mkdir p.join(path, "public"), ->
                    write p.join(path, "README.md"), readme
                    callback()
        (callback) ->
            mkdir p.join path, "public/scripts"
            callback()
        (callback) ->
            mkdir p.join path, "public/images"
            callback()
        (callback) ->
            mkdir p.join(path, "public/styles"), ->
                write p.join(path, "public/styles/style.styl"), stylus
                callback()
        (callback) ->
            mkdir p.join(path, "views"), ->
                write p.join(path, "views/index.jade"), index
                callback()
        (callback) ->
            start = "node_modules/supplier/node_modules/.bin/coffee " +
                "#{project}.coffee"

            pkg =
                name: project
                version: '0.0.1'
                private: true
                scripts:
                    start: start
                dependencies:
                    supplier: version
    
            write p.join(path, 'package.json'), JSON.stringify pkg, null, 2
            write "#{p.join path, project}.coffee", app

            console.log "supplier installing modules"
            npm = spawn "npm", ["install"], cwd: path

            if program.verbose
                npm.stdout.on "data", (data) ->
                    process.stdout.write data

                npm.stderr.on "data", (data) ->
                    process.stdout.write data

            npm.on "exit", (code) ->
                callback()
        (callback) ->
            write p.join(path, ".gitignore"), gitignore
            exec "which git", (error, stdout, stderr) ->
                console.log "supplier initializing git repositoty"
                if error
                    console.log error
                    return callback()
                
                unless stdout
                    console.log "git not installed"
                    return callback()

                exec "git init", { cwd: path }, (error, stdout, stderr) ->
                    console.log stdout if program.verbose

                    console.log "supplier committing"
                    exec 'git add . && git commit -m "Initial commit"',
                        { cwd: path }, (error, stdout, stderr) ->
                        console.log stdout if program.verbose
                        callback()
        ], (err, result) ->
            console.log """
                run the app:
                $ npm start
            """

exports.run = ->
    abort program.outputHelp() unless project

    emptyDirectory path, (empty) ->
        if empty || program.force
            createApplicationAt path
        else
            program.confirm 'destination exist, continue? ', (ok) ->
                if ok
                    process.stdin.destroy()
                    createApplicationAt path
                else
                    abort 'aborting'
